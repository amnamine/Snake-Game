import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Game',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: SnakeGame(),
    );
  }
}

class SnakeGame extends StatefulWidget {
  @override
  _SnakeGameState createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  static const int gridSize = 20;
  static const double cellSize = 20.0;
  List<Offset> snake = [Offset(5, 5)];
  Offset food = Offset(10, 10);
  Direction direction = Direction.right;
  bool isGameOver = false;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    const duration = Duration(milliseconds: 300);
    Timer.periodic(duration, (Timer timer) {
      if (isGameOver) {
        timer.cancel();
        showGameOverDialog();
      } else {
        moveSnake();
        checkCollision();
        checkFood();
        setState(() {});
      }
    });
  }

  void moveSnake() {
    for (int i = snake.length - 1; i > 0; i--) {
      snake[i] = snake[i - 1];
    }

    switch (direction) {
      case Direction.up:
        snake[0] = Offset(snake[0].dx, snake[0].dy - 1);
        break;
      case Direction.down:
        snake[0] = Offset(snake[0].dx, snake[0].dy + 1);
        break;
      case Direction.left:
        snake[0] = Offset(snake[0].dx - 1, snake[0].dy);
        break;
      case Direction.right:
        snake[0] = Offset(snake[0].dx + 1, snake[0].dy);
        break;
    }
  }

  void checkCollision() {
    if (snake[0].dy < 0 || snake[0].dy >= gridSize || snake[0].dx < 0 || snake[0].dx >= gridSize) {
      isGameOver = true;
    }

    for (int i = 1; i < snake.length; i++) {
      if (snake[i] == snake[0]) {
        isGameOver = true;
      }
    }
  }

  void checkFood() {
    if (snake[0] == food) {
      snake.add(Offset(-1, -1)); // Dummy value, will be updated in the next move
      generateFood();
    }
  }

  void generateFood() {
    final random = Random();
    int x = random.nextInt(gridSize);
    int y = random.nextInt(gridSize);

    food = Offset(x.toDouble(), y.toDouble());

    // Make sure the food is not generated on the snake
    while (snake.contains(food)) {
      x = random.nextInt(gridSize);
      y = random.nextInt(gridSize);
      food = Offset(x.toDouble(), y.toDouble());
    }
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Text('You scored ${snake.length - 1} points!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
              },
              child: Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  void resetGame() {
    snake = [Offset(5, 5)];
    food = Offset(10, 10);
    direction = Direction.right;
    isGameOver = false;
    startGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Snake Game'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: gridSize * cellSize,
              height: gridSize * cellSize,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
              child: Stack(
                children: [
                  // Draw Snake
                  for (Offset position in snake)
                    Positioned(
                      left: position.dx * cellSize,
                      top: position.dy * cellSize,
                      child: Container(
                        width: cellSize,
                        height: cellSize,
                        color: Colors.green,
                      ),
                    ),
                  // Draw Food
                  Positioned(
                    left: food.dx * cellSize,
                    top: food.dy * cellSize,
                    child: Container(
                      width: cellSize,
                      height: cellSize,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20), // Add some space between the game area and buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (direction != Direction.down) {
                          direction = Direction.up;
                        }
                      },
                      child: Text('UP'),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (direction != Direction.left) {
                              direction = Direction.left;
                            }
                          },
                          child: Text('LEFT'),
                        ),
                        SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (direction != Direction.right) {
                              direction = Direction.right;
                            }
                          },
                          child: Text('RIGHT'),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (direction != Direction.up) {
                          direction = Direction.down;
                        }
                      },
                      child: Text('DOWN'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum Direction { up, down, left, right }
