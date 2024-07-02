const std = @import("std");
const raylib = @import("raylib");
const gui = @import("raygui");

const ball_SPEED: i32 = 5;
const plank_SPEED: i32 = 5;

var GAME_ENDED = false;
var PAUSED = true;
var SCORE_Text = [_:0]u8{ '0', '0' };
// [:0]const u8    *const [2:0]u8
const Scores_array = [_]*const [2:0]u8{ "00", "01", "02", "03", "04", "05" };

const winner_array = [_]*const [12:0]u8{ "player 1 won", "player 2 won" };
var winner: u2 = undefined;

const temparray = "00"; //*const [2:0]u8
var player1ScoreText = temparray[0..];
var player2ScoreText = temparray[0..];

var player1Score: u8 = 0;
var player2Score: u8 = 0;

var dy: i32 = 1;
var dx: i32 = 1;

var color: raylib.Color = raylib.Color.init(255, 255, 255, 0);

pub fn main() !void {
    std.debug.print("working", .{});

    const screenWidth = 800;
    const screenHeight = 450;

    var ball: raylib.Vector2 = raylib.Vector2.init(screenWidth / 2, screenHeight / 2);
    var leftPlank: raylib.Rectangle = raylib.Rectangle.init(screenWidth / 15, 4, 10, 50);
    var rightPlank: raylib.Rectangle = raylib.Rectangle.init(screenWidth - (screenWidth / 15), 4, 10, 50);

    raylib.initWindow(screenWidth, screenHeight, "ping pong in zig");
    defer raylib.closeWindow(); // Close window and OpenGL context

    raylib.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!raylib.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        const temp = raylib.getKeyPressed();
        const textWidth: i32 = @as(i32, raylib.measureText("PING PONG IN ZIG", 20));
        const startText: i32 = raylib.measureText("START GAME", 16);

        if (temp != raylib.KeyboardKey.key_null) {
            std.debug.print("{any}\n", .{temp});
            if (temp == raylib.KeyboardKey.key_space) {
                PAUSED = true;
            }
        }

        if (raylib.checkCollisionCircleRec(ball, 5, leftPlank) or raylib.checkCollisionCircleRec(ball, 5, rightPlank)) {
            dx = -dx;
        }

        if (ball.x == 0) {
            player2Score += 1;
        } else if (ball.x == screenWidth) {
            player1Score += 1;
        }

        if (player1Score == 5 or player2Score == 5) {
            GAME_ENDED = true;
            winner = if (player1Score == 5) 0 else 1;
        }

        //----------------------------------------------------------------------------------
        // TODO: Update your variables here
        if (!PAUSED) {
            if (ball.y >= screenHeight or ball.y <= 0) {
                dy = -dy;
            }
            if (ball.x >= screenWidth or ball.x <= 0) {
                dx = -dx;
            }

            ball.y += @floatFromInt(ball_SPEED * dy);
            ball.x += @floatFromInt(ball_SPEED * dx);
        }

        if (raylib.isKeyDown(raylib.KeyboardKey.key_s) and leftPlank.y + leftPlank.height + plank_SPEED <= screenHeight) {
            leftPlank.y += plank_SPEED;
        }
        if (raylib.isKeyDown(raylib.KeyboardKey.key_w) and leftPlank.y - plank_SPEED >= 0) {
            leftPlank.y -= plank_SPEED;
        }

        if (raylib.isKeyDown(raylib.KeyboardKey.key_down) and rightPlank.y + rightPlank.height + plank_SPEED <= screenHeight) {
            rightPlank.y += plank_SPEED;
        }

        if (raylib.isKeyDown(raylib.KeyboardKey.key_up) and rightPlank.y - plank_SPEED >= 0) {
            rightPlank.y -= plank_SPEED;
        }

        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        raylib.beginDrawing();
        defer raylib.endDrawing();

        raylib.clearBackground(raylib.Color.black);

        if (PAUSED) {
            //raylib.drawText("game ended", screenWidth / 2, screenHeight / 2, 20, raylib.Color.white);
            _ = gui.guiGroupBox(raylib.Rectangle.init(200, 100, 400, 250), "menu");

            raylib.drawText("PING PONG IN ZIG", 400 - @divExact(textWidth, 2), 120, 20, raylib.Color.white);
            const buttonInput = gui.guiButton(raylib.Rectangle.init(400 - 50, 180, @floatFromInt(startText), @as(f32, 20)), "START GAME");
            if (buttonInput == 1) {
                PAUSED = false;
            }
        } else if (GAME_ENDED) {
            player1Score = 0;
            player2Score = 0;
            _ = gui.guiGroupBox(raylib.Rectangle.init(200, 100, 400, 250), "GAME ENDED");

            raylib.drawText("GAME OVER", 400 - @divExact(textWidth, 2), 120, 20, raylib.Color.white);
            raylib.drawText(winner_array[winner], 400 - @divExact(textWidth, 2), 180, 20, raylib.Color.white);

            const buttonInput = gui.guiButton(raylib.Rectangle.init(400 - 50, 250, @floatFromInt(startText), @as(f32, 20)), "Restart");
            if (buttonInput == 1) {
                GAME_ENDED = false;
                PAUSED = true;
            }
        } else {
            //game components
            raylib.drawCircleV(ball, 5, raylib.Color.white);
            raylib.drawRectangleRec(leftPlank, raylib.Color.white);
            raylib.drawRectangleRec(rightPlank, raylib.Color.white);

            //center strip
            raylib.drawRectangle(screenWidth / 2 - 2, 0, 4, screenHeight, raylib.Color.white);

            //players scores
            raylib.drawText(Scores_array[player1Score][0..], (screenWidth / 4) - 10, 4, 16, raylib.Color.white);
            raylib.drawText(Scores_array[player2Score][0..], screenWidth / 2 + (screenWidth / 4), 4, 16, raylib.Color.white);
        }
        //----------------------------------------------------------------------------------
    }
}
