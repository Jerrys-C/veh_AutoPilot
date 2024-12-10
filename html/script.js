window.addEventListener('message', function(event) {
    if (event.data.transactionType === 'autosteer_enabled') {
        document.getElementById('autosteer_enabled').play();
    } else if (event.data.transactionType === 'noa_enabled') {
        document.getElementById('noa_enabled').play();
    } else if (event.data.transactionType === 'autosteer_disabled') {
        document.getElementById('autosteer_disabled').play();
    } else if (event.data.transactionType === 'hands_on_steering_wheel') {
        document.getElementById('hands_on_steering_wheel').play();
    } else if (event.data.transactionType === 'autopilot_alert') {
        document.getElementById('autopilot_alert').play();
    } else if (event.data.transactionType === 'forward_collision_warning') {
        document.getElementById('forward_collision_warning').play();
    } else if (event.data.transactionType === 'noa_disabled') {
        document.getElementById('noa_disabled').play();
    }
});
