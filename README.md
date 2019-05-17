# Smartphone Text Entry Method

A prototype for a text entry method for a smartwatch created using Processing to simulate a 1 inch by 1 inch smartwatch panel on an Android device.

This scaffold uses the following features:
* server-based handwriting recognition using Tesseract to improve the speed of text input
* server-based autocomplete suggestions and autocorrect to improve accuracy

All of the processing is done on a RESTful Python server. Requests are sent to the server via POST requests with base64 encoding of written character or currently typed string as the payload.

This was designed for a class project (name and number obfuscated intentionally) along with group members [Vinit Shah](mailto:vinitsha@andrew.cmu.edu) and [David Chukwuma](mailto:dchukwuma@africa.cmu.edu).

**NOTE:** If you happened to stumble across this repository while brainstorming ideas for you-know-which-class, please don't rip off this design. You'll learn a lot more and enjoy a lot more if you try and work through this assignment with your team.
