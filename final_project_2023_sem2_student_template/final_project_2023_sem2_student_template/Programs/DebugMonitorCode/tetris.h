#ifndef JLIB_H_
#define JLIB_H_


#define OCTL_TETRIS_DEFAULT    (0xA2)

#define MILLISECONDS_PER_SEC (1000)

#define TETRIS_ROWS 20
#define TETRIS_COLS 15
#define TRUE 1
#define FALSE 0
#define INITIAL_TETRIS_SPEED (2)
#define TETRIS_SPEED_INCREASE (1)
#define NUM_SHAPES (7)
#define MAX_SHAPE_SIZE (4)
#define NUM_LINE_SUCCESS_MESSAGES (3)
#define RED_COLOR    (0x4)
#define GREEN_COLOR  (0x2)
#define BLUE_COLOR   (0x1)
#define TETRIS_COLOR (GREEN_COLOR)
#define cursor_x *(char*)(0xFF010000)
#define cursor_x1 *(char*)(0xFF010001)
#define cursor_y *(char*)(0xFF010002)
#define cursor_y1 *(char*)(0xFF010003)
#define screen_width 80
#define screen_height 40
#define VGA_ADDRESS 0xFFFF0000 
#define voice *(char*)(0xFF00FFFE)

#endif