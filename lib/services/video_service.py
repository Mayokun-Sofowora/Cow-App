import flet as ft
import requests
import base64
from flet import Page, Image, Container

# Function to fetch video frame data
def fetch_video_data():
    url = "http://140.116.86.242:25582/stream_video"
    print("Sending request to the server...")
    try:
        response = requests.get(url, timeout=10)
        print("Received response from the server.")
        response.raise_for_status()
        return response.json()
    except requests.exceptions.Timeout:
        print("Request timed out.")
        return None
    except requests.exceptions.RequestException as e:
        print(f"Request failed: {e}")
        return None

# Function to display the fetched video frame in Flet
def display_frame(page: Page, image_widget: Image):
    video_data = fetch_video_data()

    if video_data and video_data.get("result") == "success":
        image_data = video_data.get("img")
        bounding_boxes = video_data.get("data")
        
        # Decode base64 image data
        image_bytes = base64.b64decode(image_data)
        # Save image to file (for example, "frame_image.png")
        with open("frame_image.png", "wb") as f:
            f.write(image_bytes)
        
        # Set the image widget's source to the updated image
        image_widget.src = "frame_image.png"
        page.update()
    else:
        print("No valid data received.")
        image_widget.src = None
        page.update()

# Flet app to display the video
def main(page: Page):
    page.title = "Live Cow Stream"
    
    # Add image widget to display the frames
    image_widget = Image(src="", width=500, height=300, fit=ft.ImageFit.CONTAIN)
    page.add(Container(content=image_widget))

    # Fetch and display frames repeatedly (you can use a timer or manual refresh)
    def refresh_frame(e):
        display_frame(page, image_widget)

    # Refresh button
    page.add(ft.ElevatedButton(text="Refresh Frame", on_click=refresh_frame))
    
    # Initial load
    display_frame(page, image_widget)

# Run the Flet app
ft.app(target=main)
