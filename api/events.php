<?php
require_once 'config.php';

// Note: In a real-world application, you would implement authentication and authorization checks here.
// For example, verifying a JWT token from Firebase to ensure the user is who they say they are
// and that they have permission to perform the requested action.

$conn = getDbConnection();
$method = $_SERVER['REQUEST_METHOD'];

// Handle preflight OPTIONS request for CORS
if ($method === 'OPTIONS') {
    http_response_code(204);
    exit();
}

switch ($method) {
    case 'GET':
        handleGet($conn);
        break;
    case 'POST':
        handlePost($conn);
        break;
    case 'PUT':
        handlePut($conn);
        break;
    case 'DELETE':
        handleDelete($conn);
        break;
    default:
        http_response_code(405);
        echo json_encode(['message' => 'Method Not Allowed']);
        break;
}

function handleGet($conn) {
    if (isset($_GET['producer_id'])) {
        $producer_id = $_GET['producer_id'];
        $stmt = $conn->prepare("SELECT * FROM streams WHERE producer_id = ? ORDER BY event_date DESC, event_time DESC");
        $stmt->bind_param("i", $producer_id);
        $stmt->execute();
        $result = $stmt->get_result();
        $events = $result->fetch_all(MYSQLI_ASSOC);
        echo json_encode($events);
        $stmt->close();
    } else {
        http_response_code(400);
        echo json_encode(['message' => 'Producer ID is required']);
    }
}

function handlePost($conn) {
    $data = json_decode(file_get_contents('php://input'), true);

    // Basic validation
    if (!isset($data['producer_id'], $data['title'])) {
        http_response_code(400);
        echo json_encode(['message' => 'Missing required fields: producer_id and title.']);
        return;
    }

    $producer_id = $data['producer_id'];
    $title = $data['title'];
    $description = $data['description'] ?? null;
    $event_date = $data['event_date'] ?? null;
    $event_time = $data['event_time'] ?? null;
    $price = $data['price'] ?? 0.00;
    $thumbnail_url = $data['thumbnail_url'] ?? null;
    $video_url = $data['video_url'] ?? null;

    $stmt = $conn->prepare("INSERT INTO streams (producer_id, title, description, event_date, event_time, price, thumbnail_url, video_url) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
    $stmt->bind_param("issssdss", $producer_id, $title, $description, $event_date, $event_time, $price, $thumbnail_url, $video_url);

    if ($stmt->execute()) {
        http_response_code(201);
        echo json_encode(['id' => $stmt->insert_id, 'message' => 'Event created successfully']);
    } else {
        http_response_code(500);
        echo json_encode(['message' => 'Failed to create event', 'error' => $stmt->error]);
    }
    $stmt->close();
}

function handlePut($conn) {
    if (!isset($_GET['id'])) {
        http_response_code(400);
        echo json_encode(['message' => 'Event ID is required']);
        return;
    }

    $id = $_GET['id'];
    $data = json_decode(file_get_contents('php://input'), true);

    $fields = [];
    $params = [];
    $types = '';

    // Dynamically build the query based on provided fields
    $allowed_fields = ['title', 'description', 'event_date', 'event_time', 'price', 'thumbnail_url', 'video_url'];
    foreach ($allowed_fields as $field) {
        if (isset($data[$field])) {
            $fields[] = "$field = ?";
            $params[] = $data[$field];
            $types .= ($field === 'price') ? 'd' : 's';
        }
    }

    if (empty($fields)) {
        http_response_code(400);
        echo json_encode(['message' => 'No fields to update']);
        return;
    }

    $params[] = $id;
    $types .= 'i';

    $sql = "UPDATE streams SET " . implode(', ', $fields) . " WHERE id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param($types, ...$params);

    if ($stmt->execute()) {
        echo json_encode(['message' => 'Event updated successfully']);
    } else {
        http_response_code(500);
        echo json_encode(['message' => 'Failed to update event', 'error' => $stmt->error]);
    }
    $stmt->close();
}

function handleDelete($conn) {
    if (!isset($_GET['id'])) {
        http_response_code(400);
        echo json_encode(['message' => 'Event ID is required']);
        return;
    }

    $id = $_GET['id'];

    $stmt = $conn->prepare("DELETE FROM streams WHERE id = ?");
    $stmt->bind_param("i", $id);

    if ($stmt->execute()) {
        if ($stmt->affected_rows > 0) {
            echo json_encode(['message' => 'Event deleted successfully']);
        } else {
            http_response_code(404);
            echo json_encode(['message' => 'Event not found']);
        }
    } else {
        http_response_code(500);
        echo json_encode(['message' => 'Failed to delete event', 'error' => $stmt->error]);
    }
    $stmt->close();
}

$conn->close();
?>
