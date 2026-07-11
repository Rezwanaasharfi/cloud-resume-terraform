const API_URL = "https://xakowdtv1h.execute-api.us-east-2.amazonaws.com/count";

async function updateVisitorCount() {
  try {
    const response = await fetch(API_URL);
    const data = await response.json();
    document.getElementById("visitor-count").textContent = data.count;
  } catch (error) {
    document.getElementById("visitor-count").textContent = "unavailable";
    console.error("Could not fetch visitor count:", error);
  }
}

updateVisitorCount();
