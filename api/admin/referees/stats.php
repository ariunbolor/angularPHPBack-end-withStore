<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

include_once '../../config/Database.php';
include_once '../../models/Referee.php';
include_once '../../middleware/AdminAuthMiddleware.php';

$database = new Database();
$db = $database->getConnection();

// Verify admin is authenticated
$auth = new AdminAuthMiddleware($database);
if(!$auth->authenticate()) {
    exit;
}

// Get referee ID from URL parameter
$referee_id = isset($_GET['id']) ? $_GET['id'] : null;

if(!$referee_id) {
    http_response_code(400);
    echo json_encode([
        "success" => false,
        "message" => "Referee ID is required"
    ]);
    exit;
}

$referee = new Referee($db);
$result = $referee->getStats($referee_id);

if($result) {
    http_response_code(200);
    echo json_encode([
        "success" => true,
        "data" => $result
    ]);
} else {
    http_response_code(404);
    echo json_encode([
        "success" => false,
        "message" => "No stats found"
    ]);
}