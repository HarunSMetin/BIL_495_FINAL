# BIL_495_FINAL
BIL_495_FINAL

<h1>gezBot API Documentation</h1>

<h2>Overview</h2>
<p>The gezBot API is a FastAPI application integrated with Firebase Firestore and Firebase Authentication. It's designed for managing social interactions and travel planning in a social travel application.</p>

<h2>Getting Started</h2>
<h3>Prerequisites</h3>
<ul>
  <li>Python 3.6+</li>
  <li>FastAPI</li>
  <li>Uvicorn (or any ASGI server)</li>
  <li>Firebase Admin SDK</li>
</ul>

<h3>Installation</h3>
<ol>
  <li>Clone the repository:
      <pre><code>git clone [repository_url]</code></pre>
  </li>
  <li>Install the required packages:
      <pre><code>pip install -r requirements.txt</code></pre>
  </li>
</ol>

<h3>Setting up Firebase</h3>
<ol>
  <li>Set up a Firebase project.</li>
  <li>Generate and download your Firebase Admin SDK service account key.</li>
  <li>Initialize your <code>firebase_config.py</code> with your Firebase credentials.</li>
</ol>

<h3>Running the Application</h3>
<p>Run the application using Uvicorn:
  <pre><code>uvicorn main:app --reload</code></pre>
</p>

<h2>Features</h2>
<h3>User Management</h3>
<ul>
  <li><strong>User Registration</strong>: <code>POST /register</code></li>
  <li><strong>Retrieve User</strong>: <code>GET /users/{user_id}</code></li>
</ul>

<h3>Friend Management</h3>
<ul>
  <li><strong>Send Friend Request</strong>: <code>POST /send_friend_request/{sender_id}/{receiver_id}</code></li>
  <li><strong>Accept Friend Request</strong>: <code>POST /accept_friend_request/{request_id}/{sender_id}/{receiver_id}</code></li>
</ul>

<h3>Travel Planning</h3>
<ul>
  <li><strong>Create Travel Plan</strong>: <code>POST /travels</code></li>
  <li><strong>Get Travel Plans</strong>: <code>GET /travels</code></li>
</ul>

<h3>Chat Functionality</h3>
<ul>
  <li><strong>Add Chat Message</strong>: <code>POST /chats/{travel_id}/message</code></li>
  <li><strong>Get Chat Messages</strong>: <code>GET /chats/{travel_id}/messages</code></li>
</ul>

<h3>User Preferences</h3>
<ul>
  <li><strong>Add User Options</strong>: <code>POST /userOptions/{user_id}/{travel_id}</code></li>
  <li><strong>Get User Options</strong>: <code>GET /userOptions/{travel_id}</code></li>
</ul>

<h2>Error Handling</h2>
<p>The API provides detailed error messages and appropriate HTTP status codes for various scenarios like invalid requests or server errors.</p>

<h2>Security</h2>
<p>User authentication and data security are handled using Firebase Authentication.</p>

<h2>Scalability</h2>
<p>Designed to be scalable, accommodating an increasing number of users and data transactions seamlessly.</p>

<h2>Dependencies</h2>
<p>List of dependencies can be found in <code>requirements.txt</code>.</p>

<h2>Contributing</h2>
<p>Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.</p>


<p><em>This README provides a basic guide to getting the API up and running. For more detailed documentation, see the API routes and models within the codebase.</em></p>

