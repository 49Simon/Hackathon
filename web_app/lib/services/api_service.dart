import 'dart:convert';
import 'package:web_app/models/message.dart';
import 'package:http/http.dart' as http;

class ApiService {

  /*
  Since the URL is http not https, we will use Uri.http instead of Uri.parse when sending API request.
  The url is the hostname of your API.

  The API and Token are not provided in this repo. You will need to create your own API and Token.
  using the tutorial here: 
  https://www.alibabacloud.com/blog/solution-1b-how-to-use-ecs-%2B-pai-%2B-analyticdb-for-postgresql-to-build-a-llama2-solution_600287
  */

  var url = '<HOSTNAME-OF-YOUR-API-URL>';
  final headers = {
    'Authorization': '<YOUR-API-KEY-TOKEN>',
  };

  final emailUrl = "https://api.emailjs.com/api/v1.0/email/send";
  // Create your own EmailJS account and get the serviceId, templateId and userId from there.
  // https://www.emailjs.com/
  final serviceId = "<SERVICE ID FROM EMAILJS>";
  final rescueEmailTemplateId = "<TEMPLATE ID FOR RESCUE MESSAGES FROM EMAILJS>";
  final templateId = "<TEMPLATE ID FROM EMAILJS>";
  final userId = "USER ID FROM EMAILJS";


  Future<String> fetchMessages(List<Message> messages) async {
    String convo = '';
    for (final message in messages) {
      convo += message.content;
    }

    Map<String, String> body = {
      "system": """You are helpful 911 call responder. You give very short and clear instructions to the caller.
      If you are not sure, ask very short follow up questions. 
      """,
      "query": convo
    };

    final response = await http.post(Uri.http(url), headers: headers, body: body);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load messages');
    }
  }

  Future<bool> sendIncidentReport({department, address, rescue=false}) async {
    /*
    There are two templates in EmailJS.
    One is for the normal incident report and the other is for the rescue incident report.
    Could be extended to include more templates.
    */
    final url = Uri.parse(emailUrl);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "service_id": serviceId,
        "template_id": rescue ? rescueEmailTemplateId : templateId,
        "user_id": userId,
        "template_params": {
          "department": department,
          "address": address,
        }
      })
    );
    return response.statusCode == 200;
  }
}
