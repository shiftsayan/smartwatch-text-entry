from flask import Flask, request, jsonify
from flask_restful import Api, Resource, reqparse

app = Flask(__name__)
api = Api(app)

import autocomplete
f = open("big.txt")
autocomplete.models.train_models(f.read())
autocomplete.load()

from spellchecker import SpellChecker
spell = SpellChecker()

from PIL import Image
from io import BytesIO
import pytesseract, base64

def convertToGrayscale(image):
    image = image.convert("RGB")
    datas = image.getdata()

    newData = []
    for item in datas:
        if item[0] + item[1] + item[2] < 100:
            newData.append((0, 0, 0))
        else:
            newData.append((255, 255, 255))

    image.putdata(newData)
    return image


class Autocomplete(Resource):
    def post(self, sentence):
        words = ["the"] + ["the"] + sentence.split(" ")
        predictions = autocomplete.predict(words[-2], words[-1])
        return list(map(lambda x: x[0], predictions))[:5]

class Autocorrect(Resource):
    def post(self, word):
        if (word == "dhcs"): return "dhcs"
        return spell.correction(word)

class Recognition(Resource):
    def post(self):
        s = list(request.form.to_dict().keys())[0]
        image = Image.open(BytesIO(base64.urlsafe_b64decode(s)))
        image = convertToGrayscale(image)
        ocr = pytesseract.image_to_string(image, config='--psm 10 --oem 0 -c tessedit_char_whitelist=ABCDEFGHIJKLMNOPQRSTUVWXYZ')
        return ocr

api.add_resource(Autocomplete, "/predict/<string:sentence>")
api.add_resource(Autocorrect, "/correct/<string:word>")
api.add_resource(Recognition, "/ocr")

app.run(host='0.0.0.0', debug=True) # remove debug=True when finally deploying
