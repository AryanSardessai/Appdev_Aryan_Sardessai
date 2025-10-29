This folder shows the contents of experiment no. 11
🧘 Yoga Pose Catalog (Flutter)

This project is a single-file Flutter application designed to fetch and display a catalog of yoga poses. It demonstrates robust asynchronous data fetching, error handling, and data modeling using a real-world external REST API.

🚀 Key Features

External API Integration: Fetches live yoga pose data (Sanskrit name, English name, and detailed description) from a public RESTful endpoint.

Asynchronous Data Handling: Uses FutureBuilder to manage loading states, success states, and error states during API calls.

Data Model (YogaPose): Strictly typed data model to structure the JSON response for safe consumption.

Clear UI: Displays pose data in a clean, scrollable ListView with a RefreshIndicator for manual data updates.

Details View: Tapping any pose shows a modal dialog with the full description.

💻 API Used

The application retrieves all pose data from the following external endpoint:

Resource

Endpoint

All Poses

https://yoga-api-nzy4.onrender.com/v1/poses

✨ Development History (What We Did)

The current application structure is the result of several important iterations:

Initial Setup (Mock Data with Images): The app began by using local mock data and attempted to display images.

Image Handling Challenges: Due to platform-specific constraints with dynamically provided files, we encountered repeated "Image Unavailable" errors when trying to load the uploaded image assets.

Pivot to Text-Only API: To ensure reliability and stability, we abandoned image integration and shifted focus to consuming text data reliably.

Final Integration (Live API): The local mock data was replaced entirely with a dedicated ApiService that successfully connects to the external Yoga API. This final architecture ensures data consistency and stability, demonstrating a proper implementation of the Model-View-Controller (MVC) pattern in Flutter.
