const std = @import("std");
const raylib = @import("raylib");
const gui = @import("raygui");

const ball_SPEED: i32 = 5;
const plank_SPEED: i32 = 5;

var GAME_ENDED = false;
var PAUSED = true;
var ROUND_ENDED = true;

var SCORE_Text = [_:0]u8{ '0', '0' };
// [:0]const u8    *const [2:0]u8
const Scores_array = [_]*const [2:0]u8{ "00", "01", "02", "03", "04", "05" };

const stringtemp = "player 1 won";
const winner_array = [_]*const [12:0]u8{ stringtemp, "player 2 won" };
var winner: u2 = undefined;

const temparray = "00"; //*const [2:0]u8
var player1ScoreText = temparray[0..];
var player2ScoreText = temparray[0..];

var player1Score: u8 = 0;
var player2Score: u8 = 0;

var dy: i32 = 1;
var dx: i32 = 1;

const screenWidth = 800;
const screenHeight = 450;
var delta: f32 = undefined;
var gameTime: u32 = 0;
var roundEndTime: u32 = 0;
var pauseStartTime: u32 = 0;

pub fn main() !void {
    std.debug.print("working", .{});

    var ball: raylib.Vector2 = raylib.Vector2.init(screenWidth / 2, screenHeight / 2);
    var leftPlank: raylib.Rectangle = raylib.Rectangle.init(screenWidth / 15, 4, 10, 50);
    var rightPlank: raylib.Rectangle = raylib.Rectangle.init(screenWidth - (screenWidth / 15), 4, 10, 50);

    raylib.initWindow(screenWidth, screenHeight, "ping pong in zig");
    defer raylib.closeWindow(); // Close window and OpenGL context

    raylib.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!raylib.windowShouldClose()) { // Detect window close button or ESC key
        // delta = raylib.getFrameTime() - @as(f32, raylib.getTime());
        // Update
        // const temp = raylib.getKeyPressed();

        // if (temp != raylib.KeyboardKey.key_null) {
        //     // std.debug.print("{any}\n", .{temp});
        //     if (temp == raylib.KeyboardKey.key_space) {
        //         PAUSED = true;
        //         pauseStartTime = @intFromFloat(raylib.getTime());
        //     }
        // }
        std.debug.print("{}\n", .{gameTime});

        scoreKeeper(ball);

        //----------------------------------------------------------------------------------
        // TODO: Update your variables here
        if (!PAUSED) {
            checkBallPlankCollision(&ball, &leftPlank);
            checkBallPlankCollision(&ball, &rightPlank);

            if (!ROUND_ENDED) {
                updateBallState(&ball);
            } else if (gameTime - roundEndTime == 3) {
                ROUND_ENDED = false;
            }

            plankBoundaryCheck(&leftPlank, .{ raylib.KeyboardKey.key_w, raylib.KeyboardKey.key_s });
            plankBoundaryCheck(&rightPlank, .{ raylib.KeyboardKey.key_up, raylib.KeyboardKey.key_down });
            gameTime = @intFromFloat(raylib.getTime());
            pauseStartTime = 0;
        }

        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        raylib.beginDrawing();
        defer raylib.endDrawing();

        raylib.clearBackground(raylib.Color.black);

        if (PAUSED) {
            displayMenu("menu");
            displayText("PING PONG IN ZIG", 120, 20);
            const buttonState = displayButton("START BUTTON", 180);
            if (buttonState == 1) {
                PAUSED = false;
            }
        } else if (GAME_ENDED) {
            player1Score = 0;
            player2Score = 0;
            displayMenu("GAME ENDED");
            displayText("GAME OVER", 120, 20);
            displayText(winner_array[winner], 180, 20);
            const buttonState = displayButton("RESTART", 220);
            if (buttonState == 1) {
                GAME_ENDED = false;
                PAUSED = true;
            }
        } else {
            //game components
            if (ROUND_ENDED) {
                displayText("next round in", screenHeight / 2 - 30, 22);
                displayText(Scores_array[3 - (gameTime - roundEndTime)], screenHeight / 2 + 20, 20);
            } else {
                raylib.drawCircleV(ball, 5, raylib.Color.white);
                raylib.drawRectangle(screenWidth / 2 - 2, 0, 4, screenHeight, raylib.Color.white);
            }
            raylib.drawRectangleRec(leftPlank, raylib.Color.white);
            raylib.drawRectangleRec(rightPlank, raylib.Color.white);

            //center strip

            //players scores
            raylib.drawText(Scores_array[player1Score][0..], (screenWidth / 4) - 10, 4, 20, raylib.Color.white);
            raylib.drawText(Scores_array[player2Score][0..], screenWidth / 2 + (screenWidth / 4), 4, 20, raylib.Color.white);
        }
        //----------------------------------------------------------------------------------
    }
}

fn updateBallState(ball: *raylib.Vector2) void {
    if (ball.*.y >= screenHeight or ball.*.y <= 0) {
        dy = -dy;
    }

    if (ball.*.x >= screenWidth + 40 or ball.*.x <= -40) {
        dx = -dx;
        ball.*.y = screenHeight / 2 - 5;
        ball.*.x = screenWidth / 2 - 5;
        ROUND_ENDED = true;
        roundEndTime = gameTime;
        return;
    }
    ball.*.y += @as(f32, @floatFromInt(ball_SPEED * dy));
    ball.*.x += @as(f32, @floatFromInt(ball_SPEED * dx));
}

fn plankBoundaryCheck(plank: *raylib.Rectangle, key: [2]raylib.KeyboardKey) void {
    if (raylib.isKeyDown(key[1]) and plank.y + plank.height + plank_SPEED <= screenHeight) {
        plank.*.y += plank_SPEED;
    }
    if (raylib.isKeyDown(key[0]) and plank.y - plank_SPEED >= 0) {
        plank.*.y -= plank_SPEED;
    }
}

fn checkBallPlankCollision(ball: *raylib.Vector2, plank: *raylib.Rectangle) void {
    if (raylib.checkCollisionCircleRec(ball.*, 5, plank.*)) {
        if (plank.*.x <= ball.*.x and ball.*.x <= plank.*.x + plank.*.width) {
            dy = -dy;
        } else {
            dx = -dx;
        }
    }
}

fn scoreKeeper(ball: raylib.Vector2) void {
    if (ball.x == 0) {
        player2Score += 1;
    } else if (ball.x == screenWidth) {
        player1Score += 1;
    }

    if (player1Score == 5 or player2Score == 5) {
        GAME_ENDED = true;
        winner = if (player1Score == 5) 0 else 1;
    }
}

fn displayMenu(title: [:0]const u8) void {
    _ = gui.guiGroupBox(raylib.Rectangle.init(200, 100, 400, 250), title);
}

fn displayText(text: [:0]const u8, y: i32, fontSize: i32) void {
    const textWidth: i32 = @as(i32, raylib.measureText(text, 20));
    raylib.drawText(text, 400 - @divExact(textWidth, 2), y, fontSize, raylib.Color.white);
}

fn displayButton(title: [:0]const u8, y: i32) i32 {
    const textWidth: i32 = raylib.measureText(title, 16);
    const buttonInput = gui.guiButton(raylib.Rectangle.init(400 - 50, @floatFromInt(y), @floatFromInt(textWidth), @as(f32, 20)), title);

    return buttonInput;
}
