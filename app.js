// ============================================================================
// FAIZAN AWAN PORTFOLIO - INTERACTIVE APP ENGINE & SIMULATORS
// ============================================================================

document.addEventListener('DOMContentLoaded', () => {
    initCategoryFilters();
    initMetroGraphSimulator();
    initFourierSynthesizer();
    initNightLampSimulator();
    initFpgaSimulator();
    initArcadeGame();
    initSecurityKeypad();
    loadCodeFile('collab_editor.c');
});

// ----------------------------------------------------------------------------
// 1. Projects Directory Filter
// ----------------------------------------------------------------------------
function initCategoryFilters() {
    const filterBtns = document.querySelectorAll('.filter-btn');
    const projectCards = document.querySelectorAll('.project-card');

    filterBtns.forEach(btn => {
        btn.addEventListener('click', () => {
            filterBtns.forEach(b => b.classList.remove('active'));
            btn.classList.add('active');

            const filter = btn.getAttribute('data-filter');
            projectCards.forEach(card => {
                if (filter === 'all' || card.getAttribute('data-category') === filter) {
                    card.style.display = 'flex';
                } else {
                    card.style.display = 'none';
                }
            });
        });
    });
}

// ----------------------------------------------------------------------------
// 2. Simulator Tab Switcher & Modal Opener
// ----------------------------------------------------------------------------
function switchSimTab(tabId) {
    document.querySelectorAll('.sim-tab-btn').forEach(btn => btn.classList.remove('active'));
    document.querySelectorAll('.sim-panel').forEach(panel => panel.classList.remove('active'));

    const activeTab = document.querySelector(`.sim-tab-btn[onclick*="${tabId}"]`);
    if (activeTab) activeTab.classList.add('active');

    const panel = document.getElementById(`sim-${tabId}`);
    if (panel) panel.classList.add('active');
}

function openSimulator(tabId) {
    const simSection = document.getElementById('simulators');
    simSection.scrollIntoView({ behavior: 'smooth' });
    switchSimTab(tabId);
}

// ----------------------------------------------------------------------------
// 3. Peshawar Metro Graph Dijkstra Simulator
// ----------------------------------------------------------------------------
const metroStations = [
    { id: 0, name: "Chamkani Terminal", x: 60, y: 190 },
    { id: 1, name: "Sardar Garhi", x: 140, y: 120 },
    { id: 2, name: "Bus Hospital", x: 220, y: 190 },
    { id: 3, name: "Hashtnagri", x: 300, y: 120 },
    { id: 4, name: "Khyber Bazar", x: 360, y: 240 },
    { id: 5, name: "Saddar Bazar", x: 440, y: 170 },
    { id: 6, name: "Karkhano Market", x: 500, y: 280 }
];

const metroEdges = [
    { u: 0, v: 1, w: 3.5 },
    { u: 1, v: 2, w: 2.8 },
    { u: 0, v: 2, w: 5.0 },
    { u: 2, v: 3, w: 3.1 },
    { u: 3, v: 4, w: 2.4 },
    { u: 2, v: 4, w: 4.2 },
    { u: 4, v: 5, w: 3.8 },
    { u: 5, v: 6, w: 6.5 }
];

let activePathEdges = [];

function initMetroGraphSimulator() {
    const startSelect = document.getElementById('startStation');
    const endSelect = document.getElementById('endStation');

    if (!startSelect || !endSelect) return;

    startSelect.innerHTML = '';
    endSelect.innerHTML = '';

    metroStations.forEach(st => {
        startSelect.add(new Option(st.name, st.id));
        endSelect.add(new Option(st.name, st.id));
    });

    endSelect.selectedIndex = metroStations.length - 1;
    drawMetroGraph();
}

function drawMetroGraph() {
    const canvas = document.getElementById('metroCanvas');
    if (!canvas) return;
    const ctx = canvas.getContext('2d');

    ctx.clearRect(0, 0, canvas.width, canvas.height);

    // Draw Edges
    metroEdges.forEach(edge => {
        const u = metroStations[edge.u];
        const v = metroStations[edge.v];

        const isHighlighted = activePathEdges.some(e => 
            (e.u === edge.u && e.v === edge.v) || (e.u === edge.v && e.v === edge.u)
        );

        ctx.beginPath();
        ctx.moveTo(u.x, u.y);
        ctx.lineTo(v.x, v.y);
        ctx.strokeStyle = isHighlighted ? '#00f2fe' : 'rgba(255, 255, 255, 0.15)';
        ctx.lineWidth = isHighlighted ? 5 : 2;
        if (isHighlighted) {
            ctx.shadowColor = '#00f2fe';
            ctx.shadowBlur = 10;
        } else {
            ctx.shadowBlur = 0;
        }
        ctx.stroke();

        // Edge Weight
        const midX = (u.x + v.x) / 2;
        const midY = (u.y + v.y) / 2;
        ctx.fillStyle = isHighlighted ? '#00f2fe' : '#64748b';
        ctx.font = '11px JetBrains Mono';
        ctx.fillText(`${edge.w}km`, midX - 10, midY - 6);
    });

    // Draw Nodes
    metroStations.forEach(st => {
        ctx.beginPath();
        ctx.arc(st.x, st.y, 14, 0, 2 * Math.PI);
        ctx.fillStyle = '#0f172a';
        ctx.fill();
        ctx.strokeStyle = '#00f2fe';
        ctx.lineWidth = 2;
        ctx.stroke();

        ctx.fillStyle = '#fff';
        ctx.font = '11px Inter';
        ctx.textAlign = 'center';
        ctx.fillText(st.name, st.x, st.y + 28);
    });
}

function calculateMetroPath() {
    const src = parseInt(document.getElementById('startStation').value);
    const dest = parseInt(document.getElementById('endStation').value);

    // Dijkstra Algorithm Implementation
    const n = metroStations.length;
    const dist = Array(n).fill(Infinity);
    const prev = Array(n).fill(null);
    const visited = Array(n).fill(false);

    dist[src] = 0;

    for (let i = 0; i < n; i++) {
        let u = -1;
        for (let j = 0; j < n; j++) {
            if (!visited[j] && (u === -1 || dist[j] < dist[u])) {
                u = j;
            }
        }

        if (dist[u] === Infinity) break;
        visited[u] = true;

        metroEdges.forEach(edge => {
            let v = -1, w = edge.w;
            if (edge.u === u) v = edge.v;
            else if (edge.v === u) v = edge.u;

            if (v !== -1 && !visited[v]) {
                if (dist[u] + w < dist[v]) {
                    dist[v] = dist[u] + w;
                    prev[v] = u;
                }
            }
        });
    }

    // Reconstruct Path
    const pathNodes = [];
    activePathEdges = [];
    let curr = dest;
    while (curr !== null) {
        pathNodes.unshift(curr);
        curr = prev[curr];
    }

    for (let i = 0; i < pathNodes.length - 1; i++) {
        activePathEdges.push({ u: pathNodes[i], v: pathNodes[i+1] });
    }

    drawMetroGraph();

    const totalKm = dist[dest].toFixed(1);
    const estMins = Math.round(totalKm * 2.5);
    const farePkr = Math.max(20, Math.round(totalKm * 8));

    const pathNames = pathNodes.map(id => metroStations[id].name).join(" ➔ ");
    document.getElementById('pathText').innerText = pathNames;
    document.getElementById('pathDist').innerText = `${totalKm} km`;
    document.getElementById('pathTime').innerText = `${estMins} mins`;
    document.getElementById('pathFare').innerText = `PKR ${farePkr}`;
}

// ----------------------------------------------------------------------------
// 4. Fourier Series Signal Synthesizer
// ----------------------------------------------------------------------------
let harmonicsN = 7;
let freqHz = 2.0;

function initFourierSynthesizer() {
    drawFourierWave();
}

function updateHarmonics(val) {
    harmonicsN = parseInt(val);
    document.getElementById('harmonicsVal').innerText = harmonicsN;
    drawFourierWave();
}

function updateFreq(val) {
    freqHz = parseFloat(val);
    document.getElementById('freqVal').innerText = `${freqHz} Hz`;
    drawFourierWave();
}

function drawFourierWave() {
    const canvas = document.getElementById('fourierCanvas');
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    const type = document.getElementById('fourierWaveType').value;

    ctx.clearRect(0, 0, canvas.width, canvas.height);

    // Grid lines
    ctx.strokeStyle = 'rgba(255, 255, 255, 0.05)';
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(0, canvas.height/2);
    ctx.lineTo(canvas.width, canvas.height/2);
    ctx.stroke();

    // Plot Synthesized Fourier Wave
    ctx.beginPath();
    ctx.strokeStyle = '#00f2fe';
    ctx.lineWidth = 2.5;

    const midY = canvas.height / 2;
    const amp = 80;

    for (let x = 0; x < canvas.width; x++) {
        const t = (x / canvas.width) * (2 * Math.PI) * freqHz;
        let y = 0;

        for (let n = 1; n <= harmonicsN; n++) {
            if (type === 'square') {
                if (n % 2 !== 0) {
                    y += (4 / (Math.PI * n)) * Math.sin(n * t);
                }
            } else if (type === 'sawtooth') {
                y += (2 / (Math.PI * n)) * Math.sin(n * t) * (n % 2 === 0 ? -1 : 1);
            } else if (type === 'triangle') {
                if (n % 2 !== 0) {
                    y += (8 / (Math.PI * Math.PI * n * n)) * Math.sin(n * t) * (((n-1)/2) % 2 === 0 ? 1 : -1);
                }
            }
        }

        const plotY = midY - (y * amp);
        if (x === 0) ctx.moveTo(x, plotY);
        else ctx.lineTo(x, plotY);
    }

    ctx.stroke();
}

// ----------------------------------------------------------------------------
// 5. AVR Smart Night Lamp Circuit Simulator
// ----------------------------------------------------------------------------
function updateNightLamp() {
    const lux = parseInt(document.getElementById('luxSlider').value);
    const temp = parseInt(document.getElementById('tempSlider').value);

    document.getElementById('luxVal').innerText = `${lux} Lux`;
    document.getElementById('tempVal').innerText = `${temp} °C`;

    // Duty Cycle OCR0A (Inverse of Lux)
    // Darker (Lux=0) -> Duty = 255 (Full brightness)
    let duty = Math.max(0, Math.min(255, Math.round(255 - (lux / 500) * 255)));

    const bulb = document.getElementById('virtualLamp');
    const brightness = duty / 255;
    bulb.style.background = `rgba(255, 230, 100, ${brightness})`;
    bulb.style.boxShadow = `0 0 ${duty / 5}px rgba(255, 230, 100, ${brightness})`;

    document.getElementById('regOCR0A').innerText = `${duty} / 255 (${Math.round((duty/255)*100)}%)`;

    // Overheat Alarm Check (Temp >= 70°C)
    const sirenBox = document.getElementById('overheatSirenBox');
    const sirenText = document.getElementById('sirenText');

    if (temp >= 70) {
        sirenBox.classList.add('alarm');
        sirenText.innerText = `OVERHEAT WARNING! (${temp}°C)`;
        playBeepTone(1200, 100);
    } else {
        sirenBox.classList.remove('alarm');
        sirenText.innerText = "TEMPERATURE NORMAL";
    }
}

function initNightLampSimulator() {
    updateNightLamp();
}

// ----------------------------------------------------------------------------
// 6. FPGA Temp Monitor Simulator
// ----------------------------------------------------------------------------
function initFpgaSimulator() {
    updateFpgaSim(35);
}

function updateFpgaSim(val) {
    const temp = parseInt(val);
    const adcCode = Math.round((temp * 1000) / 322);

    document.getElementById('adcVal').innerText = adcCode;
    document.getElementById('sevenSegDisplay').innerText = `${String(temp).padStart(3, '0')}°C`;

    const warnLed = document.getElementById('fpgaWarnLed');
    const alarmLed = document.getElementById('fpgaAlarmLed');
    const fsmState = document.getElementById('fpgaFsmState');

    if (temp >= 45) warnLed.classList.add('active-warn');
    else warnLed.classList.remove('active-warn');

    if (temp >= 75) {
        alarmLed.classList.add('active-alarm');
        fsmState.innerText = "CRITICAL ALARM TRIGGERED";
        playBeepTone(2000, 120);
    } else {
        alarmLed.classList.remove('active-alarm');
        fsmState.innerText = "SAMPLE & LATCH";
    }
}

// ----------------------------------------------------------------------------
// 7. Racing Monkey Verilog Arcade Game Simulator
// ----------------------------------------------------------------------------
let arcadeRunning = false;
let monkeyY = 260;
let monkeyVy = 0;
let isJumping = false;
let isDucking = false;
let obstacleX = 640;
let obstacleType = 0; // 0=Rock, 1=Branch
let score = 0;
let gameLoopId = null;

function initArcadeGame() {
    drawArcadeFrame();
}

function startArcadeGame() {
    arcadeRunning = true;
    score = 0;
    monkeyY = 260;
    monkeyVy = 0;
    obstacleX = 640;
    document.getElementById('arcadeState').innerText = "RUNNING";
    if (gameLoopId) cancelAnimationFrame(gameLoopId);
    loopArcadeGame();
}

function loopArcadeGame() {
    if (!arcadeRunning) return;

    score += 1;
    document.getElementById('arcadeScore').innerText = String(score).padStart(4, '0');

    // Monkey Physics
    if (isJumping) {
        monkeyY += monkeyVy;
        monkeyVy += 0.8; // Gravity
        if (monkeyY >= 260) {
            monkeyY = 260;
            isJumping = false;
            monkeyVy = 0;
        }
    }

    // Move Obstacle
    obstacleX -= 6;
    if (obstacleX <= -30) {
        obstacleX = 640;
        obstacleType = Math.random() > 0.5 ? 1 : 0;
    }

    // Collision Detection
    const monkeyH = isDucking ? 24 : 44;
    const monkeyTop = monkeyY - monkeyH;

    if (obstacleX >= 70 && obstacleX <= 110) {
        if (obstacleType === 0) { // Rock at bottom (Must Jump)
            if (monkeyY >= 240) {
                arcadeRunning = false;
                document.getElementById('arcadeState').innerText = "GAME OVER!";
            }
        } else { // Branch at top (Must Duck)
            if (monkeyTop <= 230 && !isDucking) {
                arcadeRunning = false;
                document.getElementById('arcadeState').innerText = "GAME OVER!";
            }
        }
    }

    drawArcadeFrame();

    if (arcadeRunning) {
        gameLoopId = requestAnimationFrame(loopArcadeGame);
    }
}

function drawArcadeFrame() {
    const canvas = document.getElementById('arcadeCanvas');
    if (!canvas) return;
    const ctx = canvas.getContext('2d');

    // Sky Background
    ctx.fillStyle = '#061325';
    ctx.fillRect(0, 0, canvas.width, canvas.height);

    // Ground
    ctx.fillStyle = '#10b981';
    ctx.fillRect(0, 260, canvas.width, 100);

    // Monkey Character (Gold Box)
    const monkeyH = isDucking ? 24 : 44;
    ctx.fillStyle = '#f59e0b';
    ctx.fillRect(80, monkeyY - monkeyH, 32, monkeyH);

    // Obstacle
    if (obstacleType === 0) { // Rock
        ctx.fillStyle = '#f43f5e';
        ctx.fillRect(obstacleX, 230, 24, 30);
    } else { // High Branch
        ctx.fillStyle = '#8b5cf6';
        ctx.fillRect(obstacleX, 190, 30, 40);
    }
}

function arcadeJump() {
    if (!isJumping && arcadeRunning) {
        isJumping = true;
        monkeyVy = -11;
    }
}

function arcadeReleaseJump() {}

function arcadeDuck() {
    if (!isJumping && arcadeRunning) isDucking = true;
}

function arcadeReleaseDuck() {
    isDucking = false;
}

document.addEventListener('keydown', (e) => {
    if (e.code === 'Space' || e.code === 'ArrowUp') arcadeJump();
    if (e.code === 'ArrowDown') arcadeDuck();
});

document.addEventListener('keyup', (e) => {
    if (e.code === 'ArrowDown') arcadeReleaseDuck();
});

// ----------------------------------------------------------------------------
// 8. Smart Security Keypad & Siren Simulator
// ----------------------------------------------------------------------------
let pinInput = "";
let secState = "DISARMED"; // DISARMED, ARMED, ALARM

function initSecurityKeypad() {
    updateSecurityLcd();
}

function pressKey(k) {
    playBeepTone(1500, 40);

    if (k === 'A' && secState === "DISARMED") {
        secState = "ARMED";
        pinInput = "";
        updateSecurityLcd("Status: ARMED", "Enter PIN:");
        return;
    }

    if (k === '*') {
        pinInput = "";
        updateSecurityLcd(secState === "ARMED" ? "Status: ARMED" : "Status: DISARMED", "Enter PIN:");
        return;
    }

    if (k === '#') {
        if (pinInput === "1234") {
            secState = "DISARMED";
            pinInput = "";
            updateSecurityLcd("Status: DISARMED", "Press A to Arm");
        } else {
            updateSecurityLcd("WRONG PIN!", "Try Again");
            pinInput = "";
        }
        return;
    }

    if (pinInput.length < 4 && !isNaN(k)) {
        pinInput += k;
        updateSecurityLcd(secState === "ARMED" ? "Status: ARMED" : "Status: DISARMED", "*".repeat(pinInput.length));
    }
}

function triggerSensorAlert(reason) {
    if (secState === "ARMED") {
        secState = "ALARM";
        updateSecurityLcd("!! ALARM ALERT !", reason);
        playSirenSound();
    }
}

function updateSecurityLcd(line1 = "Status: DISARMED", line2 = "Press A to Arm") {
    document.getElementById('lcdLine1').innerText = line1;
    document.getElementById('lcdLine2').innerText = line2;
}

// ----------------------------------------------------------------------------
// 9. Collaborative Socket Text Editor Sync Simulator
// ----------------------------------------------------------------------------
function syncCollabText(clientNum) {
    const c1 = document.getElementById('client1Text');
    const c2 = document.getElementById('client2Text');
    const log = document.getElementById('socketLog');

    const sourceVal = clientNum === 1 ? c1.value : c2.value;
    if (clientNum === 1) c2.value = sourceVal;
    else c1.value = sourceVal;

    const time = new Date().toLocaleTimeString();
    const logItem = document.createElement('div');
    logItem.innerText = `[${time}] [SOCKET RECV] Client ${clientNum} sent ${sourceVal.length} bytes -> Broadcasted to all.`;
    log.appendChild(logItem);
    log.scrollTop = log.scrollHeight;
}

// ----------------------------------------------------------------------------
// 10. Hotel Booking UI Demo
// ----------------------------------------------------------------------------
function bookRoomDemo(roomName, price) {
    const box = document.getElementById('bookingReceipt');
    const details = document.getElementById('receiptDetails');

    box.classList.remove('hidden');
    details.innerHTML = `Booked <strong>${roomName}</strong> for 2 Nights.<br>Total Price: <strong>$${price * 2}</strong>. Booking Reference #HB-2026-${Math.floor(1000 + Math.random() * 9000)}.`;
}

// ----------------------------------------------------------------------------
// 11. Code Explorer Source File Loader
// ----------------------------------------------------------------------------
const filePathsMap = {
    'collab_editor.c': 'projects/collaborative-text-editor/collab_editor.c',
    'metro_graph.cpp': 'projects/metro-graph/metro_graph.cpp',
    'smart_night_lamp.c': 'projects/smart-night-lamp-overheat-alarm/smart_night_lamp.c',
    'fpga_temp_monitor.v': 'projects/fpga-temperature-monitor/fpga_temp_monitor.v',
    'tb_fpga_temp_monitor.v': 'projects/fpga-temperature-monitor/tb_fpga_temp_monitor.v',
    'spartan6_pins.ucf': 'projects/fpga-temperature-monitor/spartan6_pins.ucf',
    'racing_monkey_top.v': 'projects/racing-monkey-verilog/racing_monkey_top.v',
    'vga_controller.v': 'projects/racing-monkey-verilog/vga_controller.v',
    'monkey_game_logic.v': 'projects/racing-monkey-verilog/monkey_game_logic.v',
    'monkey_sprite_rom.v': 'projects/racing-monkey-verilog/monkey_sprite_rom.v',
    'smart_security_alarm.ino': 'projects/smart-security-alarm-system/smart_security_alarm.ino',
    'smart_security_alarm_baremetal.c': 'projects/smart-security-alarm-system/smart_security_alarm_baremetal.c',
    'fourier_series_analysis.m': 'projects/fourier-series-analysis/fourier_series_analysis.m',
    'mobile_chatbot.py': 'projects/mobile-chatbot/mobile_chatbot.py',
    'schema.sql': 'projects/hotel-booking-system/database/schema.sql',
    'triggers.sql': 'projects/hotel-booking-system/database/triggers.sql'
};

const codeSnippets = {
    'collab_editor.c': `// Multithreaded C Socket Collaborative Text Editor
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <pthread.h>
#include <time.h>

#define PORT 8080
#define MAX_CLIENTS 10
#define BUFFER_SIZE 1024

typedef struct {
    int socket;
    struct sockaddr_in address;
} client_t;

client_t *clients[MAX_CLIENTS];
pthread_mutex_t clients_mutex = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t file_mutex = PTHREAD_MUTEX_INITIALIZER;

void broadcast_message(char *message, int sender_socket) {
    pthread_mutex_lock(&clients_mutex);
    for (int i = 0; i < MAX_CLIENTS; ++i) {
        if (clients[i] && clients[i]->socket != sender_socket) {
            send(clients[i]->socket, message, strlen(message), 0);
        }
    }
    pthread_mutex_unlock(&clients_mutex);
}

void *handle_client(void *arg) {
    char buffer[BUFFER_SIZE];
    int n;
    client_t *cli = (client_t *)arg;
    while ((n = recv(cli->socket, buffer, sizeof(buffer), 0)) > 0) {
        buffer[n] = '\\0';
        broadcast_message(buffer, cli->socket);
    }
    close(cli->socket);
    free(cli);
    return NULL;
}`,
    'metro_graph.cpp': `// Metro Graph Shortest Path Finder using Dijkstra Algorithm
#include <iostream>
#include <climits>
#include <cstring>
using namespace std;

const int MAX_STATIONS = 100;
struct Edge { int to; int weight; Edge* next; };
struct Station { Edge* head; };

class MetroGraph {
    int numStations;
    Station stations[MAX_STATIONS];
public:
    MetroGraph(int stations) : numStations(stations) {
        for (int i = 0; i < MAX_STATIONS; ++i) stations[i].head = NULL;
    }
    void addEdge(int u, int v, int weight) {
        Edge* newEdge = new Edge{v, weight, stations[u].head};
        stations[u].head = newEdge;
    }
};`,
    'vga_controller.v': `// Standard 640x480 @ 60Hz VGA Sync Generator (25 MHz pixel clock)
module vga_controller (
    input  wire       clk_25MHz,  // 25 MHz Pixel Clock
    input  wire       reset,      // Active High Reset
    output wire       hsync,      // Horizontal Sync
    output wire       vsync,      // Vertical Sync
    output wire       video_on,   // Active Video Region Flag
    output reg  [9:0] pixel_x,    // Current Pixel X coordinate (0-639)
    output reg  [9:0] pixel_y     // Current Pixel Y coordinate (0-479)
);
    parameter HD = 640; // Horizontal Display Width
    parameter HF = 16;  // Horizontal Front Porch
    parameter HR = 96;  // Horizontal Retrace Pulse Width
    parameter HB = 48;  // Horizontal Back Porch
    parameter HT = 800; // Total Horizontal Pixels
    // VGA Sync Logic Implementation...
endmodule`
};

async function loadCodeFile(filename) {
    document.querySelectorAll('.file-item').forEach(item => item.classList.remove('active'));
    const activeItem = Array.from(document.querySelectorAll('.file-item')).find(item => item.innerText.includes(filename));
    if (activeItem) activeItem.classList.add('active');

    document.getElementById('activeFileName').innerText = filename;
    const codeArea = document.getElementById('codeDisplayArea');
    
    // Set static snippet preview
    if (codeSnippets[filename]) {
        codeArea.innerText = codeSnippets[filename];
    } else {
        codeArea.innerText = "// Loading " + filename + " source code...";
    }

    // Dynamic fetch from project directory
    if (filePathsMap[filename]) {
        try {
            const resp = await fetch('/' + filePathsMap[filename]);
            if (resp.ok) {
                const text = await resp.text();
                codeArea.innerText = text;
            }
        } catch (e) {
            console.log("Serving static code snippet for " + filename);
        }
    }
}

function copyCodeContent() {
    const code = document.getElementById('codeDisplayArea').innerText;
    navigator.clipboard.writeText(code).then(() => {
        alert("Source code copied to clipboard!");
    });
}

// ----------------------------------------------------------------------------
// Audio Synthesizer Beep & Siren Helper
// ----------------------------------------------------------------------------
function playBeepTone(freq, duration) {
    try {
        const audioCtx = new (window.AudioContext || window.webkitAudioContext)();
        const osc = audioCtx.createOscillator();
        const gain = audioCtx.createGain();

        osc.type = 'sine';
        osc.frequency.setValueAtTime(freq, audioCtx.currentTime);
        gain.gain.setValueAtTime(0.05, audioCtx.currentTime);

        osc.connect(gain);
        gain.connect(audioCtx.destination);

        osc.start();
        osc.stop(audioCtx.currentTime + (duration / 1000));
    } catch(e) {}
}

function playSirenSound() {
    try {
        const audioCtx = new (window.AudioContext || window.webkitAudioContext)();
        const osc = audioCtx.createOscillator();
        const gain = audioCtx.createGain();

        osc.type = 'sawtooth';
        osc.frequency.setValueAtTime(800, audioCtx.currentTime);
        osc.frequency.exponentialRampToValueAtTime(2200, audioCtx.currentTime + 0.3);

        gain.gain.setValueAtTime(0.08, audioCtx.currentTime);
        osc.connect(gain);
        gain.connect(audioCtx.destination);

        osc.start();
        osc.stop(audioCtx.currentTime + 0.4);
    } catch(e) {}
}
