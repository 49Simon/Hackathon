# ResQ AI

This is the github repo for the project ResQ AI presented at the AI InnovateFest 2023 organized by Alibaba Cloud. 

ResQ AI is Llama powered app for 911 emergencies. It is a chatbot for emergency response and allows users to report emergency cases and it provides relevant instruction/guides based on their situation.  

## Demo Video

[![Demo Video](https://img.youtube.com/vi/M0fCHvjByuc/0.jpg)](https://www.youtube.com/watch?v=M0fCHvjByuc)


## Sections
This section has both the mobile app version and the website version. 
* The directory `web_app` contains the code for the mobile app.
* The directory `website` contains the code for the website. 

## Getting Started

This project uses Alibaba Cloud platform to host the Llama-7B model. 

1. Firstly, you will need an API from Alibaba's Elastic Algorithm Service. 

    This [Tutorial](https://www.alibabacloud.com/blog/solution-1b-how-to-use-ecs-%2B-pai-%2B-analyticdb-for-postgresql-to-build-a-llama2-solution_600287) by Dr. Farruh provides a detailed step-by-step guide.

    Once you successfully create the API, you will get the `API url` and `authentication token`. 

    You need to put these in the `lib/services/api_service.dart` in lines 16 & 18. 

2. Secondly, EmailJS is used to send custom emails. You need to create an account in [EmailJS](https://emailjs.com). <br>

    You grab the `serviceId`, `templateId` and `userId` and you insert them in `lib/services/api_service.dart` in lines 24-27. 

    **Note**: For demo purposes, I have only used two template IDs. You can create templates for each service provided by ResQ AI and customize the emails as needed. 


That's it! 

Now to run the mobile app:
```flutter
cd web_app
flutter run
```

To run the website version:
```flutter
cd website
flutter run
```


## Questions or Issues?
Create an issue and I will look into it.