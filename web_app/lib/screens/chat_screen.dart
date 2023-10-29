import 'package:flutter/material.dart';
import 'package:web_app/models/message.dart';
import 'package:web_app/services/api_service.dart';
import 'package:web_app/screens/typing_animation.dart';
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
  bool _aiSendingSOS = false;
  bool _showSOSOptions = false;
  bool _sendingSOSMessage = false;
  bool _sendSOSMessageDone = false;

  bool _sendingSOSMessageF = false;
  bool _sendSOSMessageDoneF = false;

  bool _sendingSOSMessageM = false;
  bool _sendSOSMessageDoneM = false;

  bool _sendingSOSMessageR = false;
  bool _sendSOSMessageDoneR = false;

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
    
    if (!_isScrolledToBottom()) scrollToBottom(offset: 10);
    _messageController.clear();
    setState(() {
      isThinking = true;
    });
    String reply = await apiService.fetchMessages(messages.sublist(5));
    messages.add(Message(content: reply.trim(), sender: 'chatbot'));
    
    if (!_isScrolledToBottom()) scrollToBottom(offset: 700);
    setState(() {
      isThinking = false;
    });
    // if model decides its time to send dispatch request
    if (reply.toLowerCase().contains("sending dispatch request")) {
      scrollToBottom(offset: 230);
      if (reply.toLowerCase().contains("police")) {
        await Future.delayed(const Duration(milliseconds: 2700));
        showToast(text: "Sending dispatch request ....", length: "short");
        setState(() {
          _aiSendingSOS = true;
        });
        var loc = _determinePosition(accessLocation: true);
        bool success = await apiService.sendIncidentReport(department: "Police Department", address: loc.toString());
        if (success) {
          showToast(text: "Police Department dispatch request sent! Hang tight!");
          setState(() {
            _aiSendingSOS = false;
          });
          await Future.delayed(const Duration(milliseconds: 1200));
        }
      } else if (reply.toLowerCase().contains("fire")) {
        await Future.delayed(const Duration(milliseconds: 2700));
        showToast(text: "Sending dispatch request ....", length: "short");
        setState(() {
          _aiSendingSOS = true;
        });
        var loc = _determinePosition(accessLocation: true);
        bool success = await apiService.sendIncidentReport(department: "Fire Department", address: loc.toString());
        if (success) {
          showToast(text: "Fire Department dispatch request sent! Hang tight!");
          setState(() {
            _aiSendingSOS = false;
          });
          await Future.delayed(const Duration(milliseconds: 1200));
        }
      } else if (reply.toLowerCase().contains("medical")) {
        await Future.delayed(const Duration(milliseconds: 2700));
        showToast(text: "Sending dispatch request ....", length: "short");
        setState(() {
          _aiSendingSOS = true;
        });
        var loc = _determinePosition(accessLocation: true);
        bool success = await apiService.sendIncidentReport(department: "Medical Department", address: loc.toString());
        if (success) {
          showToast(text: "Medical Department dispatch request sent! Hang tight!");
          setState(() {
            _aiSendingSOS = false;
          });
          await Future.delayed(const Duration(milliseconds: 1200));
        }
      } else if (reply.toLowerCase().contains("rescue")) {
        await Future.delayed(const Duration(milliseconds: 2700));
        showToast(text: "Sending dispatch request ....", length: "short");
        setState(() {
          _aiSendingSOS = true;
        });
        var loc = _determinePosition(accessLocation: true);
        bool success = await apiService.sendIncidentReport(department: "Rescue Department", address: loc.toString());
        if (success) {
          showToast(text: "Rescue Department dispatch request sent! Hang tight!");
          setState(() {
            _aiSendingSOS = false;
          });
          await Future.delayed(const Duration(milliseconds: 1200));
        }
      }
    } else {
      setState(() {
        _showSOSOptions = false;
        _sendingSOSMessage = false;
        _sendingSOSMessageF = false;
        _sendingSOSMessageM = false;
        _sendingSOSMessageR = false;
      });
    } 
    
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
          appBar: AppBar(
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const SizedBox(width: 16,),
                  Image.asset('assets/images/logo.png', width: 50, height: 60,),
                  const SizedBox(width: 8,),
                  const Text('ResQ AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),)
                ]
              ),
            ),
            leadingWidth: 250,
            backgroundColor: Colors.red[700],
            elevation: 0.0,
            actions: [
              InkWell(
                onTap: () async {
                  await _determinePosition();
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.location_on, color: Colors.white,),
                ),
              )
            ],
          ),
          body: Stack(
            children: [
              Column(
                children: [
                    const SizedBox(height: 10,),
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
                            child: (index == messages.length - 1) & !isThinking ? 
                            Container(
                              margin: const EdgeInsets.only(bottom: 120, top: 12, left: 12, right: 12),
                              padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 12),
                              decoration: BoxDecoration(
                                color: isUserMessage ? const Color.fromARGB(255, 87, 87, 248) : const Color.fromARGB(255, 213, 214, 247),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: SizedBox(
                                width: message.content.length > 25 ? MediaQuery.of(context).size.width * 0.6 : null,
                                child: index == 1 || index == 2 || index == 3 || index == 4 ?
                                InkWell(
                                  onTap: () {
                                    switch (index) {
                                      case 1:
                                        _messageController.text = "There is robbery at my house. Please help";
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
                            ) :
                            Container(
                              margin: const EdgeInsets.only(right: 8.0, top: 8.0, left: 8.0),
                              padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 12),
                              decoration: BoxDecoration(
                                color: isUserMessage ? const Color.fromARGB(255, 87, 87, 248) : const Color.fromARGB(255, 213, 214, 247),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: SizedBox(
                                width: message.content.length > 25 ? MediaQuery.of(context).size.width * 0.6 : null,
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
                  Container(
                    color: Colors.grey[150],
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 6),
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
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                            ),
                          ),
                          AvatarGlow(
                            glowColor: const Color.fromARGB(255, 167, 17, 17),
                            animate: _isListening,
                            endRadius: 25.0,
                            duration: const Duration(milliseconds: 1500),
                            repeat: true,
                            repeatPauseDuration: const Duration(milliseconds: 100),
                            child: IconButton(
                              icon: _showMic & _isListening ? const Icon(Icons.mic_rounded, size: 28) : 
                              _showMic ? const Icon(Icons.mic_rounded, size: 28,) :
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
                ],
              ),
              Positioned(
                bottom: 90,
                right: 20,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _showSOSOptions = !_showSOSOptions;
                      _sendSOSMessageDone = false;
                      _sendSOSMessageDoneF = false;
                      _sendSOSMessageDoneM = false;
                      _sendSOSMessageDoneR = false;
                      _sendingSOSMessage = false;
                      _sendingSOSMessageF = false;
                      _sendingSOSMessageM = false;
                      _sendingSOSMessageR = false;
                    });
                  },
                  child: Tooltip(
                    message: _showSOSOptions ? "Click to cancel" :"Click to request help.",
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.red[700],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: _aiSendingSOS ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2,) :
                      _showSOSOptions ? const Icon(Icons.close, color: Colors.white, size: 30,) :
                      const Icon(Icons.sos, color: Colors.white, size: 30,),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: _showSOSOptions,
                child: Positioned(
                  bottom: 75,
                  right: 93,
                  child: InkWell(
                    onTap: () async {
                      setState(() {
                        _sendingSOSMessage = !_sendingSOSMessage;
                      });
                  
                      var loc = await _determinePosition(accessLocation: true);
                      bool success = await apiService.sendIncidentReport(department: "Police Department", address: loc.toString());
                  
                      setState(() {
                        _sendSOSMessageDone = true;
                        _sendingSOSMessage = !_sendingSOSMessage;
                      });
                      await Future.delayed(const Duration(milliseconds: 1200));
                      setState(() {
                        _showSOSOptions = !_showSOSOptions;
                      });    
                  
                      if (success) {
                        showToast(text: "Police Department dispatch request sent! Hang tight!");
                      }               
                    },
                    child: Column(
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.red[700],
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: _sendingSOSMessage ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2,) :
                          _sendSOSMessageDone ? const Icon(Icons.check, color: Colors.white, size: 30,) :
                          const Icon(Icons.local_police_rounded, color: Colors.white, size: 30,),
                        ),
                        const SizedBox(height: 5,),
                        const Text("Police", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),)
                      ],
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: _showSOSOptions,
                child: Positioned(
                  bottom: 75,
                  right: 155,
                  child: InkWell(
                    onTap: () async {
                      setState(() {
                        _sendingSOSMessageF = !_sendingSOSMessageF;
                      });
                  
                      var loc = await _determinePosition(accessLocation: true);
                      bool success = await apiService.sendIncidentReport(department: "Fire Department", address: loc.toString());
                  
                      setState(() {
                        _sendSOSMessageDoneF = true;
                        _sendingSOSMessageF = !_sendingSOSMessageF;
                      });
                      await Future.delayed(const Duration(milliseconds: 1200));
                      setState(() {
                        _showSOSOptions = !_showSOSOptions;
                      }); 
                  
                      if (success) {
                        showToast(text: "Fire Department dispatch request sent! Hang tight!");
                      }
                    },
                    child: Column(
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.red[700],
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: _sendingSOSMessageF ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2,) :
                          _sendSOSMessageDoneF ? const Icon(Icons.check, color: Colors.white, size: 30,) :
                          const Icon(Icons.fire_extinguisher, color: Colors.white, size: 30,),
                        ),
                        const SizedBox(height: 5,),
                        const Text("Firefighters", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),)
                      ],
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: _showSOSOptions,
                child: Positioned(
                  bottom: 75,
                  right: 247,
                  child: InkWell(
                    onTap: () async {
                      setState(() {
                        _sendingSOSMessageM = !_sendingSOSMessageM;
                      });
                  
                      var loc = await _determinePosition(accessLocation: true);
                      bool success = await apiService.sendIncidentReport(department: "Health Department", address: loc.toString());
                  
                      setState(() {
                        _sendSOSMessageDoneM = true;
                        _sendingSOSMessageM = !_sendingSOSMessageM;
                      });
                      await Future.delayed(const Duration(milliseconds: 1200));
                      setState(() {
                        _showSOSOptions = !_showSOSOptions;
                      }); 
                      
                      if (success) {
                        showToast(text: "Health Department dispatch request sent! Hang tight!");
                      }
                    },
                    child: Column(
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.red[700],
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: _sendingSOSMessageM ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2,) :
                          _sendSOSMessageDoneM ? const Icon(Icons.check, color: Colors.white, size: 30,) :
                          const Icon(Icons.medical_services, color: Colors.white, size: 30,),
                        ),
                        const SizedBox(height: 5,),
                        const Text("Ambulance", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),)
                      ],
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: _showSOSOptions,
                child: Positioned(
                  bottom: 75,
                  right: 337,
                  child: InkWell(
                    onTap: () async {
                     setState(() {
                        _sendingSOSMessageR = !_sendingSOSMessageR;
                      });
                  
                      var loc = await _determinePosition(accessLocation: true);                  
                      bool success = await apiService.sendIncidentReport(department: "Rescue Department", address: loc.toString(), rescue: true);
                  
                      setState(() {
                        _sendSOSMessageDoneR = true;
                        _sendingSOSMessageR = !_sendingSOSMessageR;
                      });
                      await Future.delayed(const Duration(milliseconds: 1200));
                      setState(() {
                        _showSOSOptions = !_showSOSOptions;
                      }); 
                      
                      if (success) {
                        showToast(text: "Rescue Department dispatch request sent! Hang tight!");
                      }
                    },
                    child: Column(
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.red[700],
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: _sendingSOSMessageR ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2,) :
                          _sendSOSMessageDoneR ? const Icon(Icons.check, color: Colors.white, size: 30,) :
                          const Icon(Icons.flood, color: Colors.white, size: 30,),
                        ),
                        const SizedBox(height: 5,),
                        const Text("Rescue", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),)
                      ],
                    ),
                  ),
                ),
              ),
            ]
          ),
        );
  }
}
