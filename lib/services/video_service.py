import cv2
import numpy as np
import base64
import json
import requests
from flask import Flask, Response
from flask_cors import CORS

app = Flask(__name__)
CORS(app, origins=["http://localhost:5000"])


def draw_bboxes(img, bboxes):
    for bbox in bboxes:
        track_id, x, y, w, h, action = bbox
        color = (0, 255, 0)  # Green box
        label = f"ID: {track_id}, Action: {action}"

        # Draw the bounding box on the image
        cv2.rectangle(img, (x, y), (w, h), color, 2)
        cv2.putText(img, label, (x, y - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)

    return img


def generate_video_stream(url):
    try:
        response = requests.get(url, stream=True)
        for line in response.iter_lines():
            if line:
                try:
                    json_data = line.decode("utf-8").replace("data: ", "")
                    data = json.loads(json_data)
                    jpg_original = base64.b64decode(data["image"])
                    jpg_as_np = np.frombuffer(jpg_original, dtype=np.uint8)
                    img = cv2.imdecode(jpg_as_np, cv2.IMREAD_COLOR)
                    bbox_data = data["bbox"]
                    img_with_bboxes = draw_bboxes(img, bbox_data)
                    _, jpeg = cv2.imencode(".jpg", img_with_bboxes)
                    yield (
                        b"--frame\r\n"
                        b"Content-Type: image/jpeg\r\n\r\n" + jpeg.tobytes() + b"\r\n"
                    )
                except json.JSONDecodeError as e:
                    print(f"JSON decode error: {e}")
        response.close()
    except requests.exceptions.RequestException as e:
        print(f"Request error: {e}")


@app.route("/stream_video")
def stream_video():
    return Response(
        generate_video_stream("http://140.116.86.242:25582/stream_video"),
        mimetype="multipart/x-mixed-replace; boundary=frame",
    )


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
