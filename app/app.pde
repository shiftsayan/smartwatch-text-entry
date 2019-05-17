import java.util.Arrays;
import java.util.Collections;
import java.util.Random;
import http.requests.*;
import java.util.*;
import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
// To be uncommented if using in Java Mode
// import processing.svg.*;
// import com.sun.org.apache.xerces.internal.impl.dv.util.Base64;

import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import javax.imageio.ImageIO;
import java.net.URLEncoder;

// To be commented if using on Java mode
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Base64;

// Stock variables
String[] phrases; // contains all of the phrases
int totalTrialNum = 2; // the total number of phrases to be tested - set this low for testing. Might be ~10 for the real bakeoff!
int currTrialNum = 0; // the current trial number (indexes into trials array above)
float startTime = 0; // time starts when the first letter is entered
float finishTime = 0; // records the time of when the final trial ends
float lastTime = 0; // the timestamp of when the last trial was completed
float lettersEnteredTotal = 0; // a running total of the number of letters the user has entered (need this for final WPM computation)
float lettersExpectedTotal = 0; // a running total of the number of letters expected (correct phrases)
float errorsTotal = 0; // a running total of the number of errors (when hitting next)
String currentPhrase = ""; // the current target phrase
String currentTyped = ""; // what the user has typed so far
final int DPIofYourDeviceScreen = 443; // you will need to look up the DPI or PPI of your device to make sure you get the right scale!!
// http:// en.wikipedia.org/wiki/List_of_displays_by_pixel_density
final float sizeOfInputArea = DPIofYourDeviceScreen*1; // aka, 1.0 inches square!

PImage watch;

// New variables
boolean runOnce = true;
boolean loopAgain = true;

String autocorrectURL = "http:// 128.237.118.138:5000/correct/";
String autocompleteURL = "http:// 128.237.118.138:5000/predict/";
String ocrURL = "http:// 128.237.118.138:5000/ocr";

char currentLetter = 'a';

String predicted1 = "";
String predicted2 = "";
String predicted3 = "";
String predictedArray[];

color notPressed = color(83,89,175);
color pressed = color(0,51,102);
color notPressed2 = color(0,51,102);

color letterButtonColor1 = notPressed;
color letterButtonColor2 = notPressed;
color letterButtonColor3 = notPressed;
color letterButtonColor4 = notPressed;
color letterButtonColor5 = notPressed;
color letterButtonColor6 = notPressed;
color letterButtonColor7 = notPressed;
String autoCompText = "";

PostRequest autocorrect;
PostRequest autocomplete;
PostRequest ocr;

void setup() {
    watch = loadImage("watchhand3smaller.png");
    phrases = loadStrings("phrases2.txt"); // load the phrase set into memory
    Collections.shuffle(Arrays.asList(phrases), new Random()); // randomize the order of the phrases with no seed
    // Collections.shuffle(Arrays.asList(phrases), new Random(100)); // randomize the order of the phrases with seed 100; same order every time, useful for testing

    orientation(LANDSCAPE); // can also be PORTRAIT - sets orientation on android device
    size(2160, 1080); // Sets the size of the app. You should modify this to your device's native size. Many phones today are 1080 wide by 1920 tall.
    textFont(createFont("Arial", 30)); // set the font to arial 24. Creating fonts is expensive, so make difference sizes once in setup, not draw
    noStroke(); // my code doesn't use any strokes
}


void draw() {
    // To avoid the code erasing the draw
    if(runOnce) {
        background(255); // clear background
        drawWatch(); // draw watch background
        fill(255);
        noStroke();
        rect(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2, sizeOfInputArea, sizeOfInputArea); // input area should be 1" by 1"
        runOnce = false;
    }

    stroke(255);
    if (mousePressed) {
        strokeWeight(10);
        stroke(0);
        line(mouseX, mouseY, pmouseX, pmouseY);
    }

    if (finishTime!=0)
    {
        fill(128);
        textAlign(CENTER);
        text("Finished", 280, 150);
        return;
    }

    if (startTime==0 & !mousePressed)
    {
        // fill(0);
        // textAlign(CENTER);
        // text("Click to start time!", 280, 150); // display this messsage until the user clicks!
    }

    if (startTime==0 & mousePressed)
    {
        nextTrial(); // start the trials!
    }

    if (startTime!=0)
    {
        // feel free to change the size and position of the target/entered phrases and next button
        textAlign(LEFT); // align the text left
        fill(0);
        text("Phrase " + (currTrialNum+1) + " of " + totalTrialNum, 70, 50); // draw the trial count
        fill(0);
        text("Target:   " + currentPhrase, (width/2) - 140, 100); // draw the target string
        text("Entered:  " + currentTyped +"|", (width/2) - 140, 140); // draw what the user has entered thus far

        strokeWeight(0);
        // draw very basic next button
        fill(255, 0, 0);
        rect(600, 600, 200, 200); // draw next button
        fill(0);
        text("NEXT > ", 650, 650); // draw next label

        // Letter buttons
        fill(0,0,255); // q
        rect(width/2 -sizeOfInputArea, height/2+sizeOfInputArea/4 + 30, sizeOfInputArea/5, sizeOfInputArea/6);
        fill(255);
        text(predicted1, width/2-sizeOfInputArea/2 + 5, height/2+sizeOfInputArea/4 + 60);

        // Predict
        fill(0,0,255); // q
        rect(width/2-sizeOfInputArea/2, height/2+sizeOfInputArea/4 + 30, sizeOfInputArea/3, sizeOfInputArea/6);
        fill(255);
        text(predicted1, width/2-sizeOfInputArea/2 + 5, height/2+sizeOfInputArea/4 + 60);

        fill(0,0,255); // q
        rect(width/2-sizeOfInputArea/2 +sizeOfInputArea/3+ 5, height/2+sizeOfInputArea/4 + 30, sizeOfInputArea/3, sizeOfInputArea/6); // draw left red button
        fill(255);
        text(predicted2, width/2-sizeOfInputArea/2 +sizeOfInputArea/3+ 10, height/2+sizeOfInputArea/4 + 60);

        fill(0,0,255); // q
        rect(width/2-sizeOfInputArea/2 +sizeOfInputArea/3 +sizeOfInputArea/3+ 10, height/2+sizeOfInputArea/4 + 30, sizeOfInputArea/3, sizeOfInputArea/6); // draw left red button
        fill(255);
        text(predicted3, width/2-sizeOfInputArea/2 +sizeOfInputArea/3 +sizeOfInputArea/3+ 15, height/2+sizeOfInputArea/4 + 60);

        // Red Button - Delete Character
        fill(255, 0, 0);
        rect(width/2-sizeOfInputArea/2, height/2+sizeOfInputArea/2, sizeOfInputArea/4, sizeOfInputArea/4);
        fill(255);
        text("DEL", width/2-sizeOfInputArea/2 + 25, height/2+sizeOfInputArea/2 + 50);

        // Green Button - Confirm Character
        fill(0, 255, 0);
        rect(width/2+sizeOfInputArea-(0.75*sizeOfInputArea), height/2+sizeOfInputArea/2, sizeOfInputArea/4, sizeOfInputArea/4);
        fill(0);
        text("CONFIRM", width/2+sizeOfInputArea-(0.75*sizeOfInputArea), height/2+sizeOfInputArea/2 + 50);

        // White Button - Space
        rect(width/2+sizeOfInputArea-(1.25*sizeOfInputArea), height/2+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/4); // draw right green button
        fill(0);
        text("SPACE", width/2+sizeOfInputArea-(1.25*sizeOfInputArea) + 75, height/2+sizeOfInputArea/2 + 50);// draw left red button
    }
}

void mousePressed()
{
    // Delete button
    if (didMouseClick(width/2-sizeOfInputArea/2, height/2+sizeOfInputArea/2, sizeOfInputArea/4, sizeOfInputArea/3)) // check if click occured in letter area
    {
        if(currentTyped.length()>0)
            currentTyped = currentTyped.substring(0, currentTyped.length()-1);
        runOnce = true;
    }

    // Confirm button
    if (didMouseClick(width/2+sizeOfInputArea-(0.75*sizeOfInputArea), height/2+sizeOfInputArea/2, sizeOfInputArea/4, sizeOfInputArea/3)) // check if click occured in letter area
    {
        PImage capture = get((int)(width/2-sizeOfInputArea/2), (int)(height/2-sizeOfInputArea/2), (int)(sizeOfInputArea), (int)(0.75*sizeOfInputArea));
        try {
            // ocr = new PostRequest(ocrURL);
            JSONObject obj = new JSONObject();
            obj.put("base64", EncodePImageToBase64(capture));
            String reply = "";

            try {
                reply = sendingPostRequest(EncodePImageToBase64(capture));
            } catch(Exception e) {

            }

            f(reply.length() >= 3) {
                currentTyped += reply.toLowerCase().substring(1,2);
            }
        }
        catch(IOException e) {

        }

        runOnce = true;
        String autocompleted = "";

        try {
            autocompleted = sendingPostRequestAutoComplete(getFormattedInput());
        } catch(Exception e) {
                System.out.println(e);
        }

        predictedArray = autocompleted.split(",");

        if(predictedArray.length >= 3)
        {
            predicted1 = predictedArray[0].replaceAll("[^a-zA-Z ]", "");
            predicted2 = predictedArray[1].replaceAll("[^a-zA-Z ]", "");
            predicted3 = predictedArray[2].replaceAll("[^a-zA-Z ]", "");
            // println(predictedArray[0].replaceAll("[^a-zA-Z ]", ""));
        }

        if(predictedArray.length == 2)
        {
            predicted1 = predictedArray[0].replaceAll("[^a-zA-Z ]", "");
            predicted2 = predictedArray[1].replaceAll("[^a-zA-Z ]", "");
            predicted3 = "";
            // println(predictedArray[0].replaceAll("[^a-zA-Z ]", ""));
        }

        if(predictedArray.length == 1)
        {
            predicted1 = predictedArray[0].replaceAll("[^a-zA-Z ]", "");
            predicted2 = "";
            predicted3 = "";
            // println(predictedArray[0].replaceAll("[^a-zA-Z ]", ""));
        }
    }

    // Space button
    if (didMouseClick(width/2+sizeOfInputArea-(1.25*sizeOfInputArea), height/2+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/3)) // check if click occured in letter area
    {
        currentTyped += " ";
        runOnce = true;

        String autocorrected ="";

        try{
            autocorrected = sendingPostRequestAutoCorrect(getLastWord());
        } catch(Exception e) {
            System.out.println(e);
        }

        autoCompText = autocorrected;
        autoCompText = autoCompText.replaceAll("[^a-zA-Z ]", "").trim();

        int index = currentTyped.lastIndexOf(" ",currentTyped.length());
        int indexFrontSpace = currentTyped.indexOf(" ",0);
        // println(index);

        if (index == indexFrontSpace)
        {
            if (!currentTyped.equalsIgnoreCase(autoCompText))
                currentTyped = autoCompText + " ";
        }

        else if (index > 0)
        {
            currentTyped =  currentTyped.substring(0,currentTyped.length()-1);
            index = currentTyped.lastIndexOf(" ",currentTyped.length());

            String word = getLastWord();
            if (!word.equalsIgnoreCase(autoCompText))
                currentTyped = currentTyped.substring(0,index) + " " + autoCompText + " ";
            else
                currentTyped = currentTyped+" ";

        }
    }

    // Next button to change the trial
    if (didMouseClick(600, 600, 200, 200))
    {
        nextTrial();
        runOnce = true;
    }

    // Prediction buttons
    if (didMouseClick(width/2-sizeOfInputArea/2, height/2+sizeOfInputArea/4 + 30, sizeOfInputArea/3, sizeOfInputArea/6)) // check if click occured in letter area
    {
        runOnce = true;
        int index = currentTyped.lastIndexOf(" ",currentTyped.length());
        // println(index);

        if (index == -1)
        {
            currentTyped = predicted1.trim()+ " ";
            predicted1 ="";
            predicted2 ="";
            predicted3 ="";
        }

        else if (index > 0)
        {
            currentTyped = currentTyped.substring(0,index) + " " + predicted1.trim() + " ";
            predicted1 ="";
            predicted2 ="";
            predicted3 ="";
        }

        runOnce = true;
    }

    if (didMouseClick(width/2-sizeOfInputArea/2 +sizeOfInputArea/3+ 5, height/2+sizeOfInputArea/4 + 30, sizeOfInputArea/3, sizeOfInputArea/6)) // check if click in right button
    {
        runOnce = true;
        int index = currentTyped.lastIndexOf(" ",currentTyped.length());
        // println(index);

        if (index == -1)
        {
            currentTyped = predicted2.trim()+ " ";
            predicted1 = "";
            predicted2 = "";
            predicted3 = "";
        }

        else if (index > 0)
        {
            currentTyped = currentTyped.substring(0,index) + " " + predicted2.trim() + " ";
            predicted1 = "";
            predicted2 = "";
            predicted3 = "";
        }
    }

    if (didMouseClick(width/2-sizeOfInputArea/2 +sizeOfInputArea/3 +sizeOfInputArea/3+ 10, height/2+sizeOfInputArea/4 + 30, sizeOfInputArea/3, sizeOfInputArea/6)) // check if click in right button
    {
        runOnce = true;
        int index = currentTyped.lastIndexOf(" ",currentTyped.length());
        println(index);

        if (index == -1)
        {
            currentTyped = predicted3.trim() + " ";
            predicted1 = "";
            predicted2 = "";
            predicted3 = "";
        }

        else if (index > 0)
        {
            currentTyped = currentTyped.substring(0,index) + " " + predicted3.trim() + " ";
            predicted1 = "";
            predicted2 = "";
            predicted3 = "";
        }
    }
}

// my terrible implementation you can entirely replace
boolean didMouseClick(float x, float y, float w, float h) // simple function to do hit testing
{
    return (mouseX > x && mouseX<x+w && mouseY>y && mouseY<y+h); // check to see if it is in button bounds
}

void mouseReleased()
{

}

void drawWatch()
{
    float watchscale = DPIofYourDeviceScreen/138.0;
    pushMatrix();
    translate(width/2, height/2);
    scale(watchscale);
    imageMode(CENTER);
    image(watch, 0, 0);
    popMatrix();
}

void nextTrial()
{
    if (currTrialNum >= totalTrialNum) // check to see if experiment is done
        return; // if so, just return

    if (startTime!=0 && finishTime==0) // in the middle of trials
    {
        System.out.println("==================");
        System.out.println("Phrase " + (currTrialNum+1) + " of " + totalTrialNum); // output
        System.out.println("Target phrase: " + currentPhrase); // output
        System.out.println("Phrase length: " + currentPhrase.length()); // output
        System.out.println("User typed: " + currentTyped); // output
        System.out.println("User typed length: " + currentTyped.length()); // output
        System.out.println("Number of errors: " + computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim())); // trim whitespace and compute errors
        System.out.println("Time taken on this trial: " + (millis()-lastTime)); // output
        System.out.println("Time taken since beginning: " + (millis()-startTime)); // output
        System.out.println("==================");
        lettersExpectedTotal+=currentPhrase.trim().length();
        lettersEnteredTotal+=currentTyped.trim().length();
        errorsTotal+=computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim());
    }

    // probably shouldn't need to modify any of this output / penalty code.
    if (currTrialNum == totalTrialNum-1) // check to see if experiment just finished
    {
        finishTime = millis();
        System.out.println("==================");
        System.out.println("Trials complete!"); // output
        System.out.println("Total time taken: " + (finishTime - startTime)); // output
        System.out.println("Total letters entered: " + lettersEnteredTotal); // output
        System.out.println("Total letters expected: " + lettersExpectedTotal); // output
        System.out.println("Total errors entered: " + errorsTotal); // output

        float wpm = (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f); // FYI - 60K is number of milliseconds in minute
        float freebieErrors = lettersExpectedTotal*.05; // no penalty if errors are under 5% of chars
        float penalty = max(errorsTotal-freebieErrors, 0) * .5f;

        System.out.println("Raw WPM: " + wpm); // output
        System.out.println("Freebie errors: " + freebieErrors); // output
        System.out.println("Penalty: " + penalty);
        System.out.println("WPM w/ penalty: " + (wpm-penalty)); // yes, minus, becuase higher WPM is better
        System.out.println("==================");

        currTrialNum++; // increment by one so this mesage only appears once when all trials are done
        return;
    }

    if (startTime==0) // first trial starting now
    {
        System.out.println("Trials beginning! Starting timer..."); // output we're done
        startTime = millis(); // start the timer!
    }

    else
        currTrialNum++; // increment trial number

    lastTime = millis(); // record the time of when this trial ended
    currentTyped = ""; // clear what is currently typed preparing for next trial
    currentPhrase = phrases[currTrialNum]; // load the next phrase!
    // currentPhrase = "abc"; // uncomment this to override the test phrase (useful for debugging)
}


// =========SHOULD NOT NEED TO TOUCH THIS METHOD AT ALL!==============
int computeLevenshteinDistance(String phrase1, String phrase2) // this computers error between two strings
{
    int[][] distance = new int[phrase1.length() + 1][phrase2.length() + 1];

    for (int i = 0; i <= phrase1.length(); i++)
            distance[i][0] = i;
    for (int j = 1; j <= phrase2.length(); j++)
            distance[0][j] = j;

    for (int i = 1; i <= phrase1.length(); i++)
            for (int j = 1; j <= phrase2.length(); j++)
                    distance[i][j] = min(min(distance[i - 1][j] + 1, distance[i][j - 1] + 1), distance[i - 1][j - 1] + ((phrase1.charAt(i - 1) == phrase2.charAt(j - 1)) ? 0 : 1));

    return distance[phrase1.length()][phrase2.length()];
}


public String EncodePImageToBase64(PImage i_Image) throws IOException
{
    // Uncomment the lower portion if using in Java Mode and comment the other portion

    // BufferedImage buffImage = (BufferedImage)i_Image.getNative();
    // ByteArrayOutputStream out = new ByteArrayOutputStream();
    // ImageIO.write(buffImage, "jpg", out);
    // byte[] bytes = out.toByteArray();
    // return Base64.encode(bytes);

    Bitmap bmp = (Bitmap)i_Image.getNative();
    ByteArrayOutputStream out = new ByteArrayOutputStream();
    bmp.compress(Bitmap.CompressFormat.JPEG, 100, out);
    byte[] b = out.toByteArray();
    return URLEncoder.encode(Base64.encodeToString(b, Base64.DEFAULT));
}

private String sendingPostRequest(String word) throws Exception
{

    String url = ocrURL;
    URL obj = new URL(url);
    HttpURLConnection con = (HttpURLConnection) obj.openConnection();

    // Setting basic post request
    con.setRequestMethod("POST");
    // con.setRequestProperty("User-Agent", USER_AGENT);
    // con.setRequestProperty("Accept-Language", "en-US,en;q=0.5");
    // con.setRequestProperty("Content-Type","application/json");

    String postJsonData = word;

    // Send post request
    con.setDoOutput(true);
    DataOutputStream wr = new DataOutputStream(con.getOutputStream());
    wr.writeBytes(postJsonData);
    wr.flush();
    wr.close();

    // int responseCode = con.getResponseCode();
    // System.out.println("Sending 'POST' request to URL : " + url);
    // System.out.println("Post Data : " + postJsonData);
    // System.out.println("Response Code : " + responseCode);

    BufferedReader in = new BufferedReader(
            new InputStreamReader(con.getInputStream()));
    String output;
    StringBuffer response = new StringBuffer();

    while ((output = in.readLine()) != null) {
            response.append(output);
    }
    in.close();

    // printing result from response
    // System.out.println(response.toString());

    return response.toString();
}

private String sendingPostRequestAutoComplete(String word) throws Exception
{
    String url = autocompleteURL;
    URL obj = new URL(url+word);
    HttpURLConnection con = (HttpURLConnection) obj.openConnection();

    // Setting basic post request
    con.setRequestMethod("POST");
    // con.setRequestProperty("User-Agent", USER_AGENT);
    // con.setRequestProperty("Accept-Language", "en-US,en;q=0.5");
    // con.setRequestProperty("Content-Type","application/json");

    String postJsonData = word;

    // Send post request
    con.setDoOutput(true);
    DataOutputStream wr = new DataOutputStream(con.getOutputStream());
    wr.writeBytes(postJsonData);
    wr.flush();
    wr.close();

    int responseCode = con.getResponseCode();
    // System.out.println("Sending 'POST' request to URL : " + url);
    // System.out.println("Post Data : " + postJsonData);
    // System.out.println("Response Code : " + responseCode);

    BufferedReader in = new BufferedReader(
            new InputStreamReader(con.getInputStream()));
    String output;
    StringBuffer response = new StringBuffer();

    while ((output = in.readLine()) != null) {
            response.append(output);
    }
    in.close();

    // printing result from response
    System.out.println(response.toString());

    return response.toString();
}

String getLastWord() {
    String words[] = currentTyped.split(" ");
    return words[words.length - 1];
}

String getFormattedInput() {
    return currentTyped.replace(" ", "%20");
}

// HTTP Post request AUTOCORRECT
private String sendingPostRequestAutoCorrect(String word) throws Exception {

    String url = autocorrectURL;
    URL obj = new URL(url+word);
    HttpURLConnection con = (HttpURLConnection) obj.openConnection();

    // Setting basic post request
    con.setRequestMethod("POST");
    // con.setRequestProperty("User-Agent", USER_AGENT);
    // con.setRequestProperty("Accept-Language", "en-US,en;q=0.5");
    // con.setRequestProperty("Content-Type","application/json");

    String postJsonData = word;

    // Send post request
    con.setDoOutput(true);
    DataOutputStream wr = new DataOutputStream(con.getOutputStream());
    wr.writeBytes(postJsonData);
    wr.flush();
    wr.close();

    // int responseCode = con.getResponseCode();
    // System.out.println("Sending 'POST' request to URL : " + url);
    // System.out.println("Post Data : " + postJsonData);
    // System.out.println("Response Code : " + responseCode);

    BufferedReader in = new BufferedReader(
            new InputStreamReader(con.getInputStream()));
    String output;
    StringBuffer response = new StringBuffer();

    while ((output = in.readLine()) != null) {
            response.append(output);
    }
    in.close();

    // printing result from response
    // System.out.println(response.toString());

    return response.toString();
}
