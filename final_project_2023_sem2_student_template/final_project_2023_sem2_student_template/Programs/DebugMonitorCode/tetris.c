#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include "tetris.h"
#include "say_phoneme.h"

#define Timer1Data *(volatile unsigned char *)(0x00400030)
#define Timer1Control *(volatile unsigned char *)(0x00400032)
#define Timer1Status *(volatile unsigned char *)(0x00400032)
#define octlAddress1 *(char *)(0xFF030001)
#define octlAddress *(char *)(0xFF030000)

char Table[TETRIS_ROWS][TETRIS_COLS];
char TableColor[TETRIS_ROWS + 1][TETRIS_COLS];
char currentColor;
int tetris_score;
char GameOn;
int tetris_timer;
char octl;

typedef struct
{
	char array[MAX_SHAPE_SIZE][MAX_SHAPE_SIZE];
	int width, row, col;
} Shape;
Shape current;

Shape ShapesArray[NUM_SHAPES];

struct
{
	int speed;
	int speed_increase;
} Tetris_Speed;

int printw_x; // hint: could be a useful variable
int printw_y; // hint: could be a useful variable

char cx, cy;
int timer_count;

/* Compute x mod y using binary long division. */
int mod_bld(int x, int y)
{
	int modulus = x, divisor = y;

	while (divisor <= modulus && divisor <= 16384)
		divisor <<= 1;

	while (modulus >= y)
	{
		while (divisor > modulus)
			divisor >>= 1;
		modulus -= divisor;
	}

	return modulus;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////
//
//
//                        functions to implement
//
//
/////////////////////////////////////////////////////////////////////////////////////////////////////

void Timer_ISR()
{
	++timer_count;
	// printf("Timer ISR, %d\n", timer_count);
	Timer1Control = 3;
}
// #define StartOfExceptionVectorTable 0x08030000
// void InstallExceptionHandler(void (*function_ptr)(), int level)
// {
//     volatile long int *RamVectorAddress = (volatile long int *)(StartOfExceptionVectorTable); // pointer to the Ram based interrupt vector table created in Cstart in debug monitor

//     RamVectorAddress[level] = (long int *)(function_ptr); // install the address of our function into the exception table
// }
void Wait1ms_here(void)
{
	int what;
	for (what = 0; what < 1000; what++)
		;
}

void Wait250ms_here(void)
{
	int what;
	for (what = 0; what < 250; what++)
		Wait1ms_here();
}

void changeChar(int addr, char c)
{
	*(char *)(VGA_ADDRESS + addr * 2 + 1) = c;
	*(char *)(VGA_ADDRESS + addr * 2) = c;
}

void changeColor(int addr, char color)
{
	char change = octl & 0xF8;
	change |= color;
	octlAddress = change;
	octlAddress1 = change;
}

void writeVGAColor(int addr, char c, char color)
{
	changeColor(addr, color);
	changeChar(addr, c);
}

void writeVGA(int addr, char c)
{
	changeColor(addr, octl);
	changeChar(addr, c);
}

void updateVGAColor(int x, int y, char c, char color)
{
	writeVGAColor(y * screen_width + x, c, color);
}

void updateVGA(int x, int y, char c)
{
	writeVGA(y * screen_width + x, c);
}

void update_cursor(int x, int y)
{
	cx = x;
	cy = y;
	cursor_x = cx;
	cursor_x1 = cx;
	cursor_y = cy;
	cursor_y1 = cy;
}
void go_to_top_corner()
{
	update_cursor(0, 0);
};

void clear_screen()
{
	int i;
	for (i = 0; i <= 3200; i++)
	{
		changeChar(i, ' ');
	}
};

void say_game_over()
{
	talkphonemeGG2();
	talkphonemeEY();
	talkphonemeMM();
	endword();
	talkphonemeOW();
	talkphonemeVV();
	talkphonemeER2();
	endword();
}

void say_awesome()
{
	talkphonemeAA();
	talkphonemeSS();
	talkphonemeAO();
	talkphonemeMM();
	endword();
}

void say_cool()
{
	talkphonemeKK2();
	talkphonemeUW2();
	talkphonemeEL();
	endword();
}

void say_yeah()
{
	talkphonemeYY1();
	talkphonemeEH();
	talkphonemeEH();
	endword();
}

void putcharxyColor(int x, int y, char ch, char color, char *error_message)
{
	if (x < 0 || x >= screen_width || y < 0 || y >= screen_height)
	{
		printf("%s\n", error_message);
		// printf("x: %d, y: %d\n", x, y);
	}
	else
	{
		updateVGAColor(x, y, ch, color);
	}
}

// default color
void putcharxy(int x, int y, char ch, char *error_message)
{
	if (x < 0 || x >= screen_width || y < 0 || y >= screen_height)
	{
		printf("%s\n", error_message);
		// printf("x: %d, y: %d\n", x, y);
	}
	else
	{
		updateVGA(x, y, ch);
	}
}

void gotoxy(int x, int y)
{
	update_cursor(x, y);
};

void set_vga_control_reg(char x)
{
	// Set the value of the control register in the VGA core
	// write this function
	octl = (x & 0xF8) | (octl & 0x7);
}

char get_vga_control_reg()
{
	// Get the value of the control register in the VGA core
	// write this function
	return octl;
}

void set_color(int color)
{
	octl &= 0xF8;		   // 8'b1111_1000
	octl |= (color & 0x7); // 8'b0000_0111
}

int clock()
{
	// Returns time in milliseconds since the timer was initialized
	// write this function
	return timer_count * 100;
}

void printwColor(const char *str, char color, char *error_message)
{
	int index = 0;
	while (str[index] != '\0')
	{
		if (str[index] == '\n')
		{
			printw_x = 0;
			printw_y++;
			// printf("newline\n");
		}
		else
		{
			putcharxyColor(printw_x, printw_y, str[index], color, error_message);
			printw_x++;
		}
		index++;
	}
}

// default color
void printw(const char *str, char *error_message)
{
	int index = 0;
	while (str[index] != '\0')
	{
		if (str[index] == '\n')
		{
			printw_x = 0;
			printw_y++;
			// printf("newline\n");
		}
		else
		{
			putcharxy(printw_x, printw_y, str[index], error_message);
			printw_x++;
		}
		index++;
	}
}

void display_game_over(char *str, int x, int y)
{
	int num;
	num = 0;
	while (str[num] != '\0')
	{
		Wait250ms_here();
		update_cursor(x + 1, y);
		putcharxy(x + 1, y, ' ', "game over");
		// printf("cx: %d, cy: %d\n", cx, cy);
		Wait1ms_here();
		putcharxy(x, y, str[num], "game over");
		x++;
		num++;
	}
	if (str[0] == 'S')
		update_cursor(x - 1, y);
}

void gameOver()
{
	// 36, 20: Game over!
	int test = 5000;
	char *game_over = " Game over! ";
	char score_str[128];
	char num;
	say_game_over();
	clear_screen();
	num = 1;
	sprintf(score_str, " Score: %d ", tetris_score);
	// 36, 22: Score: %d
	set_vga_control_reg(0xE0);
	printw_x = 34;
	printw_y = 20;
	display_game_over(game_over, printw_x, printw_y);
	printw_x = 34;
	printw_y = 22;
	display_game_over(score_str, printw_x, printw_y);
	FlushKeyboard() ; 
	printf("Press any key to continue\n");
	while (1)
	{
		printw_x = 34;
		printw_y = 20;
		set_color(num);
		printw(game_over, "game over");
		printw_x = 34;
		printw_y = 22;
		printw(score_str, "score");
		
		if (kbhit())
		{
			break;
		}
		Wait250ms_here();
		++num;
		if (num > 7)
		{
			num = 1;
		}
	}
	set_vga_control_reg(0xA2);
}

/////////////////////////////////////////////////////////////////////////////////////////////////////
//
//
//                      end  functions to implement
//
//
/////////////////////////////////////////////////////////////////////////////////////////////////////

void delay_ms(int num_ms)
{
	int start_time;
	int current_time;
	start_time = clock();

	do
	{
		current_time = clock();
		if (current_time < start_time)
		{ // handle wraparound
			num_ms = num_ms - (INT_MAX - start_time);
			start_time = current_time;
		}
	} while ((current_time - start_time) < num_ms);
}

int tetris_rand()
{
	return ((clock() >> 4) & 0xFFFF); // divide by 4 because clock increases by 10 every interrupt, ensure last digit is "random" too
}

void CopyShape(Shape *shape, Shape *new_shape)
{
	int i;
	int j;
	new_shape->width = shape->width;
	new_shape->row = shape->row;
	new_shape->col = shape->col;
	for (i = 0; i < new_shape->width; i++)
	{
		for (j = 0; j < new_shape->width; j++)
		{
			new_shape->array[i][j] = shape->array[i][j];
		}
	}
}

int CheckPosition(Shape *shape)
{ // Check the position of the copied shape
	int i, j;

	for (i = 0; i < shape->width; i++)
	{
		for (j = 0; j < shape->width; j++)
		{
			if ((shape->col + j < 0 || shape->col + j >= TETRIS_COLS || shape->row + i >= TETRIS_ROWS))
			{							// Out of borders
				if (shape->array[i][j]) // but is it just a phantom?
					return FALSE;
			}
			else if (Table[shape->row + i][shape->col + j] && shape->array[i][j])
				return FALSE;
		}
	}
	return TRUE;
}

void SetNewRandomShape()
{ // updates [current] with new shape
	currentColor = mod_bld(tetris_rand(), NUM_SHAPES);
	CopyShape(&ShapesArray[currentColor], &current);
	++currentColor;
	current.col = mod_bld(tetris_rand(), (TETRIS_COLS - current.width + 1));
	current.row = 0;
	if (!CheckPosition(&current))
	{
		GameOn = FALSE;
		// printf("Game on = false\n");
	}
}

void RotateShape(Shape *shape)
{ // rotates clockwise
	Shape temp;
	int i, j, k, width;
	CopyShape(shape, &temp);
	width = shape->width;
	for (i = 0; i < width; i++)
	{
		for (j = 0, k = width - 1; j < width; j++, k--)
		{
			shape->array[i][j] = temp.array[k][i];
		}
	}
}

void WriteToTable()
{
	int i, j;
	for (i = 0; i < current.width; i++)
	{
		for (j = 0; j < current.width; j++)
		{
			if (current.array[i][j])
				Table[current.row + i][current.col + j] = current.array[i][j];
		}
	}
}

void RemoveFullRowsAndUpdateScore()
{
	int i, j, sum, count = 0;
	int l, k;
	int compliment_to_say;
	for (i = 0; i < TETRIS_ROWS; i++)
	{
		sum = 0;
		for (j = 0; j < TETRIS_COLS; j++)
		{
			sum += Table[i][j];
		}
		if (sum == TETRIS_COLS)
		{
			count++;

			for (k = i; k >= 1; k--)
				for (l = 0; l < TETRIS_COLS; l++)
					Table[k][l] = Table[k - 1][l];
			for (l = 0; l < TETRIS_COLS; l++)
				Table[k][l] = 0;

			compliment_to_say = mod_bld(tetris_rand(), NUM_LINE_SUCCESS_MESSAGES);
			switch (compliment_to_say)
			{
			case 0:
				say_awesome();
				break;
			case 1:
				say_cool();
				break;
			case 2:
				say_yeah();
				break;
			default:
				say_yeah();
				break;
			}
			Tetris_Speed.speed = Tetris_Speed.speed + Tetris_Speed.speed_increase;
		}
	}
	tetris_score += 100 * count;
}

void PrintTable()
{
	int i, j;
	char score_str[128];
	char Buffer[TETRIS_ROWS][TETRIS_COLS];
	printw_x = 0;
	printw_y = 0;
	for (i = 0; i < TETRIS_ROWS; i++)
	{
		for (j = 0; j < TETRIS_COLS; j++)
		{
			Buffer[i][j] = 0;
		}
	}

	for (i = 0; i < current.width; i++)
	{
		for (j = 0; j < current.width; j++)
		{
			if (current.array[i][j])
			{
				Buffer[current.row + i][current.col + j] = current.array[i][j];
				TableColor[current.row + i][current.col + j] = currentColor;
			}
		}
	}

	go_to_top_corner();
	printw("\n\n\n", "initial_newline");
	for (i = 0; i < TETRIS_COLS - 9; i++)
	{
		printw(" ", "space");
	}
	printw("CPEN412 Tetris\n", "title");
	for (i = 0; i < TETRIS_ROWS; i++)
	{
		for (j = 0; j < TETRIS_COLS; j++)
		{
			if (Table[i][j] + Buffer[i][j])
			{
				printwColor("#", TableColor[i][j], "table#");
			}
			else
			{
				printw(".", "table.");
			}
			// printw(" ","space2");
		}
		printw("\n", "newline1");
	}

	sprintf(score_str, "\nScore: %d\n", tetris_score);
	printw(score_str, "scoreprint");
}

void ManipulateCurrent(int action)
{
	Shape temp;
	CopyShape(&current, &temp);
	switch (action)
	{
	case 's':
		temp.row++; // move down
		if (CheckPosition(&temp))
		{
			current.row++;
		}
		else
		{
			WriteToTable();
			RemoveFullRowsAndUpdateScore();
			SetNewRandomShape();
		}
		break;
	case 'd':
		temp.col++; // move right
		if (CheckPosition(&temp))
			current.col++;
		break;
	case 'a':
		temp.col--; // move left
		if (CheckPosition(&temp))
			current.col--;
		break;
	case 'w':
		RotateShape(&temp); // rotate clockwise
		if (CheckPosition(&temp))
			RotateShape(&current);
		break;
	}
	PrintTable();
}

void initTetris_Speed()
{
	Tetris_Speed.speed = INITIAL_TETRIS_SPEED;
	Tetris_Speed.speed_increase = TETRIS_SPEED_INCREASE;
}

void tetris_mainloop()
{
	int current_time;
	int got_game_over;
	while (1)
	{
		current_time = clock();
		if (kbhit())
		{
			ManipulateCurrent(getch());
			if (!GameOn)
			{
				break;
			}
		}
		if (current_time >= ((MILLISECONDS_PER_SEC / Tetris_Speed.speed) + tetris_timer))
		{
			ManipulateCurrent('s');
			if (!GameOn)
			{
				break;
			}

			tetris_timer = current_time;
		}
	}
}

// void test(){
// 	printf("Testing\n");
// 	while (1){
// 		octlAddress = 0xF3;
// 		octlAddress1 = 0xE2;
// 	}

// }
void testSound(){
    say_awesome();
	Wait250ms_here();
	say_cool();
	Wait250ms_here();
	say_yeah();
	Wait250ms_here();
	say_game_over();
	Wait250ms_here();
}
int tetris_main()
{
	int i, j;
	int test1;
	char score_str[128];
	while(1){
		testSound();
	}
	// test();
	timer_count = 0;
	printw_x = 0;
	printw_y = 0;
	GameOn = TRUE;
	InstallExceptionHandler(Timer_ISR, 30);
	Timer1Data = 0x25; // 100 ms
	Timer1Control = 3; // enable timer, periodic mode
	// InstallExceptionHandler(Timer_ISR, 29);
	// InstallExceptionHandler(Timer_ISR, 28);
	// InstallExceptionHandler(Timer_ISR, 27);
	// InstallExceptionHandler(Timer_ISR, 26);
	// InstallExceptionHandler(Timer_ISR, 25);
	octl = OCTL_TETRIS_DEFAULT;
	octlAddress = octl;

	for (j = 0; j < TETRIS_COLS; j++)
	{
		Table[0][j] = 2; // default color
		for (i = 0; i < TETRIS_ROWS; i++)
		{
			Table[i][j] = 0;
			TableColor[i + 1][j] = 2; // default color
		}
	}

	// S shape
	ShapesArray[0].array[0][0] = 0;
	ShapesArray[0].array[0][1] = 1;
	ShapesArray[0].array[0][2] = 1;
	ShapesArray[0].array[1][0] = 1;
	ShapesArray[0].array[1][1] = 1;
	ShapesArray[0].array[1][2] = 0;
	ShapesArray[0].array[2][0] = 0;
	ShapesArray[0].array[2][1] = 0;
	ShapesArray[0].array[2][2] = 0;
	ShapesArray[0].width = 3;

	// Z shape
	ShapesArray[1].array[0][0] = 1;
	ShapesArray[1].array[0][1] = 1;
	ShapesArray[1].array[0][2] = 0;
	ShapesArray[1].array[1][0] = 0;
	ShapesArray[1].array[1][1] = 1;
	ShapesArray[1].array[1][2] = 1;
	ShapesArray[1].array[2][0] = 0;
	ShapesArray[1].array[2][1] = 0;
	ShapesArray[1].array[2][2] = 0;
	ShapesArray[1].width = 3;

	// T shape
	ShapesArray[2].array[0][0] = 0;
	ShapesArray[2].array[0][1] = 1;
	ShapesArray[2].array[0][2] = 0;
	ShapesArray[2].array[1][0] = 1;
	ShapesArray[2].array[1][1] = 1;
	ShapesArray[2].array[1][2] = 1;
	ShapesArray[2].array[2][0] = 0;
	ShapesArray[2].array[2][1] = 0;
	ShapesArray[2].array[2][2] = 0;
	ShapesArray[2].width = 3;

	// L shape
	ShapesArray[3].array[0][0] = 0;
	ShapesArray[3].array[0][1] = 0;
	ShapesArray[3].array[0][2] = 1;
	ShapesArray[3].array[1][0] = 1;
	ShapesArray[3].array[1][1] = 1;
	ShapesArray[3].array[1][2] = 1;
	ShapesArray[3].array[2][0] = 0;
	ShapesArray[3].array[2][1] = 0;
	ShapesArray[3].array[2][2] = 0;
	ShapesArray[3].width = 3;

	// flipped L shape
	ShapesArray[4].array[0][0] = 1;
	ShapesArray[4].array[0][1] = 0;
	ShapesArray[4].array[0][2] = 0;
	ShapesArray[4].array[1][0] = 1;
	ShapesArray[4].array[1][1] = 1;
	ShapesArray[4].array[1][2] = 1;
	ShapesArray[4].array[2][0] = 0;
	ShapesArray[4].array[2][1] = 0;
	ShapesArray[4].array[2][2] = 0;
	ShapesArray[4].width = 3;

	// square shape
	ShapesArray[5].array[0][0] = 1;
	ShapesArray[5].array[0][1] = 1;
	ShapesArray[5].array[1][0] = 1;
	ShapesArray[5].array[1][1] = 1;
	ShapesArray[5].width = 2;

	// long bar shape
	ShapesArray[6].array[0][0] = 0;
	ShapesArray[6].array[0][1] = 0;
	ShapesArray[6].array[0][2] = 0;
	ShapesArray[6].array[0][3] = 0;
	ShapesArray[6].array[1][0] = 1;
	ShapesArray[6].array[1][1] = 1;
	ShapesArray[6].array[1][2] = 1;
	ShapesArray[6].array[1][3] = 1;
	ShapesArray[6].array[2][0] = 0;
	ShapesArray[6].array[2][1] = 0;
	ShapesArray[6].array[2][2] = 0;
	ShapesArray[6].array[2][3] = 0;
	ShapesArray[6].array[3][0] = 0;
	ShapesArray[6].array[3][1] = 0;
	ShapesArray[6].array[3][2] = 0;
	ShapesArray[6].array[3][3] = 0;
	ShapesArray[6].width = 4;
	set_color(OCTL_TETRIS_DEFAULT);
	set_vga_control_reg(OCTL_TETRIS_DEFAULT);
	tetris_score = 0;
	initTetris_Speed();
	clear_screen();

	tetris_timer = clock();
	SetNewRandomShape();
	PrintTable();
	tetris_mainloop();
	gameOver();
	for (i = 0; i < TETRIS_ROWS; i++)
	{
		for (j = 0; j < TETRIS_COLS; j++)
		{
			if (Table[i][j])
			{
				printf("#");
			}
			else
			{
				printf(".");
			}
		}
		printf("\n");
	}
	printf("\nGame over!\n");
	sprintf(score_str, "\nScore: %d\n", tetris_score);
	printf(score_str);
	return 0;
}