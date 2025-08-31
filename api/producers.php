<?php
require_once 'config.php';

$conn = getDbConnection();
$method = $_SERVER['REQUEST_METHOD'];

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
    default:
        http_response_code(405);
        echo json_encode(['message' => 'Method Not Allowed']);
        break;
}

function handleGet($conn) {
    if (isset($_GET['google_uid'])) {
        $google_uid = $_GET['google_uid'];
        $stmt = $conn->prepare("SELECT * FROM producers WHERE google_uid = ?");
        $stmt->bind_param("s", $google_uid);
        $stmt->execute();
        $result = $stmt->get_result();
        if ($producer = $result->fetch_assoc()) {
            echo json_encode($producer);
        } else {
            http_response_code(404);
            echo json_encode(['message' => 'Producer not found']);
        }
        $stmt->close();
    } else {
        http_response_code(400);
        echo json_encode(['message' => 'Google UID is required']);
    }
}

function handlePost($conn) {
    $data = json_decode(file_get_contents('php://input'), true);

    if (!isset($data['google_uid'], $data['user_name'], $data['email'])) {
        http_response_code(400);
        echo json_encode(['message' => 'Missing required fields']);
        return;
    }

    $google_uid = $data['google_uid'];
    $user_name = $data['user_name'];
    $email = $data['email'];
    $organization_name = $data['organization_name'] ?? null;
    $phone = $data['phone'] ?? null;

    $stmt = $conn->prepare("INSERT INTO producers (google_uid, user_name, email, organization_name, phone) VALUES (?, ?, ?, ?, ?)");
    $stmt->bind_param("sssss", $google_uid, $user_name, $email, $organization_name, $phone);

    if ($stmt->execute()) {
        http_response_code(201);
        echo json_encode(['id' => $stmt->insert_id, 'message' => 'Producer created successfully']);
    } else {
        http_response_code(500);
        echo json_encode(['message' => 'Failed to create producer', 'error' => $stmt->error]);
    }
    $stmt->close();
}

function handlePut($conn) {
    if (!isset($_GET['id'])) {
        http_response_code(400);
        echo json_encode(['message' => 'Producer ID is required']);
        return;
    }

    $id = $_GET['id'];
    $data = json_decode(file_get_contents('php://input'), true);

    $fields = [];
    $params = [];
    $types = '';

    if (isset($data['organization_name'])) {
        $fields[] = 'organization_name = ?';
        $params[] = $data['organization_name'];
        $types .= 's';
    }
    if (isset($data['user_name'])) {
        $fields[] = 'user_name = ?';
        $params[] = $data['user_name'];
        $types .= 's';
    }
    if (isset($data['phone'])) {
        $fields[] = 'phone = ?';
        $params[] = $data['phone'];
        $types .= 's';
    }

    if (empty($fields)) {
        http_response_code(400);
        echo json_encode(['message' => 'No fields to update']);
        return;
    }

    $params[] = $id;
    $types .= 'i';

    $sql = "UPDATE producers SET " . implode(', ', $fields) . " WHERE id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param($types, ...$params);

    if ($stmt->execute()) {
        echo json_encode(['message' => 'Producer updated successfully']);
    } else {
        http_response_code(500);
        echo json_encode(['message' => 'Failed to update producer', 'error' => $stmt->error]);
    }
    $stmt->close();
}

$conn->close();
?>
