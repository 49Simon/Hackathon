import 'package:flutter/material.dart';
import 'package:website/models/message.dart';
import 'package:website/services/api_service.dart';
import 'package:website/screens/typing_animation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:geolocator/geolocator.dart';

class ChatScreen extends StatefulWidget {

  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ApiService apiService = ApiService();

  final ScrollController _scrollController = ScrollController();

  final TextEditingController _messageController = TextEditingController();

  bool isThinking = false;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _showMic = true;

  var messages = <Message>[
    Message(content: "Hi there. I am ready to help if you have any emergency.", sender: "chatbot"),
    Message(content: "Robbery/Crime", sender: "user"),
    Message(content: "Fire", sender: "user"),
    Message(content: "Medical Emergency", sender: "user"),
    Message(content: "Natural Disaster", sender: "user"),

  ];

  void _sendMessage({bool fromVoice = false}) async {

    if (_messageController.text.trim().isEmpty) {
      _messageController.clear();
      return;
    }
    if (!fromVoice) {
      messages.add(Message(content: _messageController.text.trim(), sender: 'user'));
    }
    
    if (!_isScrolledToBottom()) scrollToBottom();
    _messageController.clear();
    setState(() {
      isThinking = true;
    });
    String reply = await apiService.fetchMessages(messages.sublist(5));
    messages.add(Message(content: reply.trim(), sender: 'chatbot'));

    if (reply.toLowerCase().contains("sending dispatch request")) {
      scrollToBottom(offset: 230);
      if (reply.toLowerCase().contains("police")) {
        await Future.delayed(const Duration(milliseconds: 2700));
        showToast(text: "Sending dispatch request ....", length: "short");
        var loc = _determinePosition(accessLocation: true);
        bool success = await apiService.sendIncidentReport(department: "Police Department", address: loc.toString());
        if (success) {
          showToast(text: "Police Department dispatch request sent! Hang tight!");
          await Future.delayed(const Duration(milliseconds: 1200));
        }
      } else if (reply.toLowerCase().contains("fire")) {
        await Future.delayed(const Duration(milliseconds: 2700));
        showToast(text: "Sending dispatch request ....", length: "short");
        var loc = _determinePosition(accessLocation: true);
        bool success = await apiService.sendIncidentReport(department: "Fire Department", address: loc.toString());
        if (success) {
          showToast(text: "Fire Department dispatch request sent! Hang tight!");
          await Future.delayed(const Duration(milliseconds: 1200));
        }
      } else if (reply.toLowerCase().contains("medical")) {
        await Future.delayed(const Duration(milliseconds: 2700));
        showToast(text: "Sending dispatch request ....", length: "short");
        var loc = _determinePosition(accessLocation: true);
        bool success = await apiService.sendIncidentReport(department: "Medical Department", address: loc.toString());
        if (success) {
          showToast(text: "Medical Department dispatch request sent! Hang tight!");
          await Future.delayed(const Duration(milliseconds: 1200));
        }
      } else if (reply.toLowerCase().contains("rescue")) {
        await Future.delayed(const Duration(milliseconds: 2700));
        showToast(text: "Sending dispatch request ....", length: "short");
        var loc = _determinePosition(accessLocation: true);
        bool success = await apiService.sendIncidentReport(department: "Rescue Department", address: loc.toString());
        if (success) {
          showToast(text: "Rescue Department dispatch request sent! Hang tight!");
          await Future.delayed(const Duration(milliseconds: 1200));
        }
      }
    } 
    
    if (!_isScrolledToBottom()) scrollToBottom();
    setState(() {
      isThinking = false;
    });
  }

  bool _isScrolledToBottom() {
    double maxScrollExtentWithPadding =
          _scrollController.position.maxScrollExtent -
          _scrollController.position.viewportDimension +
          _scrollController.position.maxScrollExtent +
          _scrollController.position.minScrollExtent;

      return _scrollController.position.pixels >= maxScrollExtentWithPadding;
  }

  void scrollToBottom({int offset=195}) {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + offset,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 800),
    );
  }

  void showToast({text, length = "long"}) {
    Fluttertoast.showToast(
      msg: text,
      toastLength: length == "short" ? Toast.LENGTH_SHORT : Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.amber,
      textColor: Colors.white,
      fontSize: 16.0
    );
  }

  void _listen(index) async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              messages[index].content = val.recognizedWords;
            });
          }
        );
      }
    } 
  }
    

  Future<Position?> _determinePosition({accessLocation = false}) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
    } 

    if (accessLocation) {
      return await Geolocator.getCurrentPosition();
    }
    return null;
  }
  
   @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

   @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.2,
                height: MediaQuery.of(context).size.height,
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(width: 1.0, color: Color.fromARGB(255, 236, 232, 232)),
                  )
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('images/logo.png', width: 280, height: 280,),
                    const SizedBox(height: 20,),
                  ],
                ),
              )
            ],
          ),
          Column(
            children: [
              Container(
                color: const Color(0xFFF4F6FD),
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  children: [
                  Column(
                  children: [
                    const SizedBox(height: 40,),
                    Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      color: const Color(0xFFF4F6FD),
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: messages.length + (isThinking ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (isThinking && index == messages.length) {
                            return TypingAnimation(_scrollController);
                          }
                          Message message = messages[index];
                          bool isUserMessage = message.sender == 'user';
                          return Align(
                            alignment: isUserMessage
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(right: 20.0, top: 8.0, left: 20.0),
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: isUserMessage ? const Color.fromARGB(255, 87, 87, 248) : const Color.fromARGB(255, 213, 214, 247),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: SizedBox(
                                width: message.content.length > 50 ? MediaQuery.of(context).size.width * 0.3 : null,
                                child: index == 1 || index == 2 || index == 3 || index == 4 ?
                                InkWell(
                                  onTap: () {
                                    switch (index) {
                                      case 1:
                                        _messageController.text = "There is robbery at my house. What should I do?";
                                        break;
                                      case 2:
                                        _messageController.text = "There is fire at my house. What should I do?";
                                        break;
                                      case 3:
                                        _messageController.text = "There is Medical Emergency. What should I do?";
                                        break;
                                      case 4:
                                        _messageController.text = "There is Natural Disaster. What should I do?";
                                        break;
                                      default:
                                    }
                                    _sendMessage();
                                  },
                                  child: Tooltip(
                                    message: "Click to send this message",
                                    child: Text(
                                      message.content,
                                      maxLines: 100,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        decoration: TextDecoration.underline,
                                        decorationStyle: TextDecorationStyle.dotted,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w400
                                        ),
                                    ),
                                  ),
                                ) :
                                Text(
                                  message.content,
                                  maxLines: 100,
                                  style: TextStyle(
                                    color: isUserMessage ? Colors.white : Colors.black,
                                    fontSize: 16.0,
                                    ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                    bottom: 60,
                    left: 90,
                    right: 60,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                enabled: !_isListening,
                                onChanged: (value) {
                                  setState(() {
                                    if (value.trim().isEmpty) {
                                      _showMic = true;
                                    } else {
                                      _showMic = false;
                                    }
                                  });
                                },
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8),
                                  hintText: 'Message ....',
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              ),
                            ),
                            AvatarGlow(
                              glowColor: Colors.red,
                              animate: _isListening,
                              endRadius: 25.0,
                              duration: const Duration(milliseconds: 1500),
                              repeat: true,
                              repeatPauseDuration: const Duration(milliseconds: 100),
                              child: IconButton(
                                icon: _showMic ? const Icon(Icons.mic_rounded, size: 28,) :
                                const Icon(Icons.send_rounded),
                                onPressed:() {
                                  if (_showMic) {
                                    int index = messages.length;
                                    if (!_isListening) {
                                      messages.add(Message(content: '', sender: 'user'));
                                      _listen(index);
                                    } else {
                                      setState(() {
                                        _isListening = false;
                                        _speech.stop();
                                        if (messages[index-1].content == '') {
                                          messages.removeAt(index-1);
                                        } else{
                                          _messageController.text = messages[index-1].content;
                                          _sendMessage(fromVoice: true);
                                        }
                                      });
                                    }
                                  } else {
                                    _sendMessage();
                                    setState(() {
                                      _showMic = true;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              Positioned(
                bottom: -85,
                left: 90,
                right: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("Powered by ",
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),),
                    Image.asset("images/alibaba.png", width: 220, height: 220,),
                  ],
                )
              )
              ]),
              )
            ],
          ),
        ]
      ),
    );
  }
}