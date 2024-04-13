; C:\USERS\10054\ONEDRIVE\CPEN 412 FINAL PROJECT\FINAL_PROJECT_2023_SEM2_STUDENT_TEMPLATE\FINAL_PROJECT_2023_SEM2_STUDENT_TEMPLATE\PROGRAMS\DEBUGMONITORCODE\TETRIS.C - Compiled by CC68K  Version 5.00 (c) 1991-2005  Peter J. Fondse
; #include <stdio.h>
; #include <stdlib.h>
; #include <limits.h>
; #include "tetris.h"
; #include "say_phoneme.h"
; #define Timer1Data *(volatile unsigned char *)(0x00400030)
; #define Timer1Control *(volatile unsigned char *)(0x00400032)
; #define Timer1Status *(volatile unsigned char *)(0x00400032)
; #define octlAddress1 *(char *)(0xFF030001)
; #define octlAddress *(char *)(0xFF030000)
; char Table[TETRIS_ROWS][TETRIS_COLS];
; char TableColor[TETRIS_ROWS + 1][TETRIS_COLS];
; char currentColor;
; int tetris_score;
; char GameOn;
; int tetris_timer;
; char octl;
; typedef struct
; {
; char array[MAX_SHAPE_SIZE][MAX_SHAPE_SIZE];
; int width, row, col;
; } Shape;
; Shape current;
; Shape ShapesArray[NUM_SHAPES];
; struct
; {
; int speed;
; int speed_increase;
; } Tetris_Speed;
; int printw_x; // hint: could be a useful variable
; int printw_y; // hint: could be a useful variable
; char cx, cy;
; int timer_count;
; /* Compute x mod y using binary long division. */
; int mod_bld(int x, int y)
; {
       section   code
       xdef      _mod_bld
_mod_bld:
       link      A6,#0
       movem.l   D2/D3,-(A7)
; int modulus = x, divisor = y;
       move.l    8(A6),D3
       move.l    12(A6),D2
; while (divisor <= modulus && divisor <= 16384)
mod_bld_1:
       cmp.l     D3,D2
       bgt.s     mod_bld_3
       cmp.l     #16384,D2
       bgt.s     mod_bld_3
; divisor <<= 1;
       asl.l     #1,D2
       bra       mod_bld_1
mod_bld_3:
; while (modulus >= y)
mod_bld_4:
       cmp.l     12(A6),D3
       blt.s     mod_bld_6
; {
; while (divisor > modulus)
mod_bld_7:
       cmp.l     D3,D2
       ble.s     mod_bld_9
; divisor >>= 1;
       asr.l     #1,D2
       bra       mod_bld_7
mod_bld_9:
; modulus -= divisor;
       sub.l     D2,D3
       bra       mod_bld_4
mod_bld_6:
; }
; return modulus;
       move.l    D3,D0
       movem.l   (A7)+,D2/D3
       unlk      A6
       rts
; }
; /////////////////////////////////////////////////////////////////////////////////////////////////////
; //
; //
; //                        functions to implement
; //
; //
; /////////////////////////////////////////////////////////////////////////////////////////////////////
; void Timer_ISR()
; {
       xdef      _Timer_ISR
_Timer_ISR:
; ++timer_count;
       addq.l    #1,_timer_count.L
; // printf("Timer ISR, %d\n", timer_count);
; Timer1Control = 3;
       move.b    #3,4194354
       rts
; }
; // #define StartOfExceptionVectorTable 0x08030000
; // void InstallExceptionHandler(void (*function_ptr)(), int level)
; // {
; //     volatile long int *RamVectorAddress = (volatile long int *)(StartOfExceptionVectorTable); // pointer to the Ram based interrupt vector table created in Cstart in debug monitor
; //     RamVectorAddress[level] = (long int *)(function_ptr); // install the address of our function into the exception table
; // }
; void Wait1ms_here(void)
; {
       xdef      _Wait1ms_here
_Wait1ms_here:
       move.l    D2,-(A7)
; int what;
; for (what = 0; what < 1000; what++)
       clr.l     D2
Wait1ms_here_1:
       cmp.l     #1000,D2
       bge.s     Wait1ms_here_3
       addq.l    #1,D2
       bra       Wait1ms_here_1
Wait1ms_here_3:
       move.l    (A7)+,D2
       rts
; ;
; }
; void Wait100ms_here(void)
; {
       xdef      _Wait100ms_here
_Wait100ms_here:
       move.l    D2,-(A7)
; int what;
; for (what = 0; what < 100; what++)
       clr.l     D2
Wait100ms_here_1:
       cmp.l     #100,D2
       bge.s     Wait100ms_here_3
; Wait1ms_here();
       jsr       _Wait1ms_here
       addq.l    #1,D2
       bra       Wait100ms_here_1
Wait100ms_here_3:
       move.l    (A7)+,D2
       rts
; }
; void Wait250ms_here(void)
; {
       xdef      _Wait250ms_here
_Wait250ms_here:
       move.l    D2,-(A7)
; int what;
; for (what = 0; what < 250; what++)
       clr.l     D2
Wait250ms_here_1:
       cmp.l     #250,D2
       bge.s     Wait250ms_here_3
; Wait1ms_here();
       jsr       _Wait1ms_here
       addq.l    #1,D2
       bra       Wait250ms_here_1
Wait250ms_here_3:
       move.l    (A7)+,D2
       rts
; }
; void Wait300ms_here(void)
; {
       xdef      _Wait300ms_here
_Wait300ms_here:
       move.l    D2,-(A7)
; int what;
; for (what = 0; what < 300; what++)
       clr.l     D2
Wait300ms_here_1:
       cmp.l     #300,D2
       bge.s     Wait300ms_here_3
; Wait1ms_here();
       jsr       _Wait1ms_here
       addq.l    #1,D2
       bra       Wait300ms_here_1
Wait300ms_here_3:
       move.l    (A7)+,D2
       rts
; }
; void changeChar(int addr, char c)
; {
       xdef      _changeChar
_changeChar:
       link      A6,#0
; *(char *)(VGA_ADDRESS + addr * 2 + 1) = c;
       move.l    #-65536,D0
       move.l    8(A6),-(A7)
       pea       2
       jsr       LMUL
       move.l    (A7),D1
       addq.w    #8,A7
       addq.l    #1,D1
       add.l     D1,D0
       move.l    D0,A0
       move.b    15(A6),(A0)
; *(char *)(VGA_ADDRESS + addr * 2) = c;
       move.l    #-65536,D0
       move.l    8(A6),-(A7)
       pea       2
       jsr       LMUL
       move.l    (A7),D1
       addq.w    #8,A7
       add.l     D1,D0
       move.l    D0,A0
       move.b    15(A6),(A0)
       unlk      A6
       rts
; }
; void changeColor(int addr, char color)
; {
       xdef      _changeColor
_changeColor:
       link      A6,#0
       move.l    D2,-(A7)
; char change = octl & 0xF8;
       move.b    _octl.L,D0
       ext.w     D0
       and.w     #248,D0
       move.b    D0,D2
; change |= color;
       move.b    15(A6),D0
       or.b      D0,D2
; octlAddress = change;
       move.b    D2,-16580608
; octlAddress1 = change;
       move.b    D2,-16580607
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; void writeVGAColor(int addr, char c, char color)
; {
       xdef      _writeVGAColor
_writeVGAColor:
       link      A6,#0
; changeColor(addr, color);
       move.b    19(A6),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       move.l    8(A6),-(A7)
       jsr       _changeColor
       addq.w    #8,A7
; changeChar(addr, c);
       move.b    15(A6),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       move.l    8(A6),-(A7)
       jsr       _changeChar
       addq.w    #8,A7
       unlk      A6
       rts
; }
; void writeVGA(int addr, char c)
; {
       xdef      _writeVGA
_writeVGA:
       link      A6,#0
; changeColor(addr, octl);
       move.b    _octl.L,D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       move.l    8(A6),-(A7)
       jsr       _changeColor
       addq.w    #8,A7
; changeChar(addr, c);
       move.b    15(A6),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       move.l    8(A6),-(A7)
       jsr       _changeChar
       addq.w    #8,A7
       unlk      A6
       rts
; }
; void updateVGAColor(int x, int y, char c, char color)
; {
       xdef      _updateVGAColor
_updateVGAColor:
       link      A6,#0
; writeVGAColor(y * screen_width + x, c, color);
       move.b    23(A6),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       move.b    19(A6),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       move.l    12(A6),-(A7)
       pea       80
       jsr       LMUL
       move.l    (A7),D1
       addq.w    #8,A7
       add.l     8(A6),D1
       move.l    D1,-(A7)
       jsr       _writeVGAColor
       add.w     #12,A7
       unlk      A6
       rts
; }
; void updateVGA(int x, int y, char c)
; {
       xdef      _updateVGA
_updateVGA:
       link      A6,#0
; writeVGA(y * screen_width + x, c);
       move.b    19(A6),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       move.l    12(A6),-(A7)
       pea       80
       jsr       LMUL
       move.l    (A7),D1
       addq.w    #8,A7
       add.l     8(A6),D1
       move.l    D1,-(A7)
       jsr       _writeVGA
       addq.w    #8,A7
       unlk      A6
       rts
; }
; void update_cursor(int x, int y)
; {
       xdef      _update_cursor
_update_cursor:
       link      A6,#0
; cx = x;
       move.l    8(A6),D0
       move.b    D0,_cx.L
; cy = y;
       move.l    12(A6),D0
       move.b    D0,_cy.L
; cursor_x = cx;
       move.b    _cx.L,-16711680
; cursor_x1 = cx;
       move.b    _cx.L,-16711679
; cursor_y = cy;
       move.b    _cy.L,-16711678
; cursor_y1 = cy;
       move.b    _cy.L,-16711677
       unlk      A6
       rts
; }
; void go_to_top_corner()
; {
       xdef      _go_to_top_corner
_go_to_top_corner:
; update_cursor(0, 0);
       clr.l     -(A7)
       clr.l     -(A7)
       jsr       _update_cursor
       addq.w    #8,A7
       rts
; };
; void clear_screen()
; {
       xdef      _clear_screen
_clear_screen:
       move.l    D2,-(A7)
; int i;
; for (i = 0; i <= 3200; i++)
       clr.l     D2
clear_screen_1:
       cmp.l     #3200,D2
       bgt.s     clear_screen_3
; {
; changeChar(i, ' ');
       pea       32
       move.l    D2,-(A7)
       jsr       _changeChar
       addq.w    #8,A7
       addq.l    #1,D2
       bra       clear_screen_1
clear_screen_3:
       move.l    (A7)+,D2
       rts
; }
; };
; void say_game_over()
; {
       xdef      _say_game_over
_say_game_over:
; talkphonemeGG1();
       jsr       _talkphonemeGG1
; talkphonemeEY();
       jsr       _talkphonemeEY
; talkphonemeMM();
       jsr       _talkphonemeMM
; endword();
       jsr       _endword
; talkphonemeOW();
       jsr       _talkphonemeOW
; talkphonemeVV();
       jsr       _talkphonemeVV
; talkphonemeER2();
       jsr       _talkphonemeER2
; endword();
       jsr       _endword
       rts
; }
; void say_awesome()
; {
       xdef      _say_awesome
_say_awesome:
; talkphonemeAA();
       jsr       _talkphonemeAA
; talkphonemeSS();
       jsr       _talkphonemeSS
; talkphonemeAO();
       jsr       _talkphonemeAO
; talkphonemeMM();
       jsr       _talkphonemeMM
; endword();
       jsr       _endword
       rts
; }
; void say_cool()
; {
       xdef      _say_cool
_say_cool:
; talkphonemeKK3();
       jsr       _talkphonemeKK3
; talkphonemeUH();
       jsr       _talkphonemeUH
; talkphonemeUH();
       jsr       _talkphonemeUH
; talkphonemeEL();
       jsr       _talkphonemeEL
; endword();
       jsr       _endword
       rts
; }
; void say_yeah()
; {
       xdef      _say_yeah
_say_yeah:
; talkphonemeYY2();
       jsr       _talkphonemeYY2
; talkphonemeEH();
       jsr       _talkphonemeEH
; talkphonemeEH();
       jsr       _talkphonemeEH
; endword();
       jsr       _endword
       rts
; }
; void putcharxyColor(int x, int y, char ch, char color, char *error_message)
; {
       xdef      _putcharxyColor
_putcharxyColor:
       link      A6,#0
       movem.l   D2/D3,-(A7)
       move.l    12(A6),D2
       move.l    8(A6),D3
; if (x < 0 || x >= screen_width || y < 0 || y >= screen_height)
       cmp.l     #0,D3
       blt.s     putcharxyColor_3
       cmp.l     #80,D3
       bge.s     putcharxyColor_3
       cmp.l     #0,D2
       blt.s     putcharxyColor_3
       cmp.l     #40,D2
       blt.s     putcharxyColor_1
putcharxyColor_3:
; {
; printf("%s\n", error_message);
       move.l    24(A6),-(A7)
       pea       @tetris_1.L
       jsr       _printf
       addq.w    #8,A7
       bra.s     putcharxyColor_2
putcharxyColor_1:
; // printf("x: %d, y: %d\n", x, y);
; }
; else
; {
; updateVGAColor(x, y, ch, color);
       move.b    23(A6),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       move.b    19(A6),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       move.l    D2,-(A7)
       move.l    D3,-(A7)
       jsr       _updateVGAColor
       add.w     #16,A7
putcharxyColor_2:
       movem.l   (A7)+,D2/D3
       unlk      A6
       rts
; }
; }
; // default color
; void putcharxy(int x, int y, char ch, char *error_message)
; {
       xdef      _putcharxy
_putcharxy:
       link      A6,#0
       movem.l   D2/D3,-(A7)
       move.l    12(A6),D2
       move.l    8(A6),D3
; if (x < 0 || x >= screen_width || y < 0 || y >= screen_height)
       cmp.l     #0,D3
       blt.s     putcharxy_3
       cmp.l     #80,D3
       bge.s     putcharxy_3
       cmp.l     #0,D2
       blt.s     putcharxy_3
       cmp.l     #40,D2
       blt.s     putcharxy_1
putcharxy_3:
; {
; printf("%s\n", error_message);
       move.l    20(A6),-(A7)
       pea       @tetris_1.L
       jsr       _printf
       addq.w    #8,A7
       bra.s     putcharxy_2
putcharxy_1:
; // printf("x: %d, y: %d\n", x, y);
; }
; else
; {
; updateVGA(x, y, ch);
       move.b    19(A6),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       move.l    D2,-(A7)
       move.l    D3,-(A7)
       jsr       _updateVGA
       add.w     #12,A7
putcharxy_2:
       movem.l   (A7)+,D2/D3
       unlk      A6
       rts
; }
; }
; void gotoxy(int x, int y)
; {
       xdef      _gotoxy
_gotoxy:
       link      A6,#0
; update_cursor(x, y);
       move.l    12(A6),-(A7)
       move.l    8(A6),-(A7)
       jsr       _update_cursor
       addq.w    #8,A7
       unlk      A6
       rts
; };
; void set_vga_control_reg(char x)
; {
       xdef      _set_vga_control_reg
_set_vga_control_reg:
       link      A6,#0
; // Set the value of the control register in the VGA core
; // write this function
; octl = (x & 0xF8) | (octl & 0x7);
       move.b    11(A6),D0
       ext.w     D0
       and.w     #248,D0
       move.b    _octl.L,D1
       and.b     #7,D1
       ext.w     D1
       or.w      D1,D0
       move.b    D0,_octl.L
       unlk      A6
       rts
; }
; char get_vga_control_reg()
; {
       xdef      _get_vga_control_reg
_get_vga_control_reg:
; // Get the value of the control register in the VGA core
; // write this function
; return octl;
       move.b    _octl.L,D0
       rts
; }
; void set_color(int color)
; {
       xdef      _set_color
_set_color:
       link      A6,#0
; octl &= 0xF8;		   // 8'b1111_1000
       and.b     #248,_octl.L
; octl |= (color & 0x7); // 8'b0000_0111
       move.l    8(A6),D0
       and.l     #7,D0
       or.b      D0,_octl.L
       unlk      A6
       rts
; }
; int clock()
; {
       xdef      _clock
_clock:
; // Returns time in milliseconds since the timer was initialized
; // write this function
; return timer_count * 100;
       move.l    _timer_count.L,-(A7)
       pea       100
       jsr       LMUL
       move.l    (A7),D0
       addq.w    #8,A7
       rts
; }
; void printwColor(const char *str, char color, char *error_message)
; {
       xdef      _printwColor
_printwColor:
       link      A6,#0
       movem.l   D2/D3/A2,-(A7)
       lea       _printw_x.L,A2
       move.l    8(A6),D3
; int index = 0;
       clr.l     D2
; while (str[index] != '\0')
printwColor_1:
       move.l    D3,A0
       move.b    0(A0,D2.L),D0
       beq       printwColor_3
; {
; if (str[index] == '\n')
       move.l    D3,A0
       move.b    0(A0,D2.L),D0
       cmp.b     #10,D0
       bne.s     printwColor_4
; {
; printw_x = 0;
       clr.l     (A2)
; printw_y++;
       addq.l    #1,_printw_y.L
       bra.s     printwColor_5
printwColor_4:
; // printf("newline\n");
; }
; else
; {
; putcharxyColor(printw_x, printw_y, str[index], color, error_message);
       move.l    16(A6),-(A7)
       move.b    15(A6),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       move.l    D3,A0
       move.b    0(A0,D2.L),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       move.l    _printw_y.L,-(A7)
       move.l    (A2),-(A7)
       jsr       _putcharxyColor
       add.w     #20,A7
; printw_x++;
       addq.l    #1,(A2)
printwColor_5:
; }
; index++;
       addq.l    #1,D2
       bra       printwColor_1
printwColor_3:
       movem.l   (A7)+,D2/D3/A2
       unlk      A6
       rts
; }
; }
; // default color
; void printw(const char *str, char *error_message)
; {
       xdef      _printw
_printw:
       link      A6,#0
       movem.l   D2/D3/A2,-(A7)
       lea       _printw_x.L,A2
       move.l    8(A6),D3
; int index = 0;
       clr.l     D2
; while (str[index] != '\0')
printw_1:
       move.l    D3,A0
       move.b    0(A0,D2.L),D0
       beq       printw_3
; {
; if (str[index] == '\n')
       move.l    D3,A0
       move.b    0(A0,D2.L),D0
       cmp.b     #10,D0
       bne.s     printw_4
; {
; printw_x = 0;
       clr.l     (A2)
; printw_y++;
       addq.l    #1,_printw_y.L
       bra.s     printw_5
printw_4:
; // printf("newline\n");
; }
; else
; {
; putcharxy(printw_x, printw_y, str[index], error_message);
       move.l    12(A6),-(A7)
       move.l    D3,A0
       move.b    0(A0,D2.L),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       move.l    _printw_y.L,-(A7)
       move.l    (A2),-(A7)
       jsr       _putcharxy
       add.w     #16,A7
; printw_x++;
       addq.l    #1,(A2)
printw_5:
; }
; index++;
       addq.l    #1,D2
       bra       printw_1
printw_3:
       movem.l   (A7)+,D2/D3/A2
       unlk      A6
       rts
; }
; }
; void display_game_over(char *str, int x, int y)
; {
       xdef      _display_game_over
_display_game_over:
       link      A6,#0
       movem.l   D2/D3/D4/D5,-(A7)
       move.l    12(A6),D2
       move.l    16(A6),D3
       move.l    8(A6),D5
; int num;
; num = 0;
       clr.l     D4
; while (str[num] != '\0')
display_game_over_1:
       move.l    D5,A0
       move.b    0(A0,D4.L),D0
       beq       display_game_over_3
; {
; Wait100ms_here();
       jsr       _Wait100ms_here
; update_cursor(x + 1, y);
       move.l    D3,-(A7)
       move.l    D2,D1
       addq.l    #1,D1
       move.l    D1,-(A7)
       jsr       _update_cursor
       addq.w    #8,A7
; putcharxy(x + 1, y, ' ', "game over");
       pea       @tetris_2.L
       pea       32
       move.l    D3,-(A7)
       move.l    D2,D1
       addq.l    #1,D1
       move.l    D1,-(A7)
       jsr       _putcharxy
       add.w     #16,A7
; // printf("cx: %d, cy: %d\n", cx, cy);
; Wait1ms_here();
       jsr       _Wait1ms_here
; putcharxy(x, y, str[num], "game over");
       pea       @tetris_2.L
       move.l    D5,A0
       move.b    0(A0,D4.L),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       move.l    D3,-(A7)
       move.l    D2,-(A7)
       jsr       _putcharxy
       add.w     #16,A7
; x++;
       addq.l    #1,D2
; num++;
       addq.l    #1,D4
       bra       display_game_over_1
display_game_over_3:
; }
; if (str[0] == 'S')
       move.l    D5,A0
       move.b    (A0),D0
       cmp.b     #83,D0
       bne.s     display_game_over_4
; update_cursor(x - 1, y);
       move.l    D3,-(A7)
       move.l    D2,D1
       subq.l    #1,D1
       move.l    D1,-(A7)
       jsr       _update_cursor
       addq.w    #8,A7
display_game_over_4:
       movem.l   (A7)+,D2/D3/D4/D5
       unlk      A6
       rts
; }
; void gameOver()
; {
       xdef      _gameOver
_gameOver:
       link      A6,#-132
       movem.l   D2/D3/A2/A3/A4,-(A7)
       lea       _printw_y.L,A2
       lea       _printw_x.L,A3
       lea       -128(A6),A4
; // 36, 20: Game over!
; int test = 5000;
       move.l    #5000,-132(A6)
; char *game_over = " Game over! ";
       lea       @tetris_3.L,A0
       move.l    A0,D3
; char score_str[128];
; char num;
; say_game_over();
       jsr       _say_game_over
; clear_screen();
       jsr       _clear_screen
; num = 1;
       moveq     #1,D2
; sprintf(score_str, " Score: %d ", tetris_score);
       move.l    _tetris_score.L,-(A7)
       pea       @tetris_4.L
       move.l    A4,-(A7)
       jsr       _sprintf
       add.w     #12,A7
; // 36, 22: Score: %d
; set_vga_control_reg(0xE0);
       pea       224
       jsr       _set_vga_control_reg
       addq.w    #4,A7
; printw_x = 34;
       move.l    #34,(A3)
; printw_y = 20;
       move.l    #20,(A2)
; display_game_over(game_over, printw_x, printw_y);
       move.l    (A2),-(A7)
       move.l    (A3),-(A7)
       move.l    D3,-(A7)
       jsr       _display_game_over
       add.w     #12,A7
; printw_x = 34;
       move.l    #34,(A3)
; printw_y = 22;
       move.l    #22,(A2)
; display_game_over(score_str, printw_x, printw_y);
       move.l    (A2),-(A7)
       move.l    (A3),-(A7)
       move.l    A4,-(A7)
       jsr       _display_game_over
       add.w     #12,A7
; FlushKeyboard() ; 
       jsr       _FlushKeyboard
; printf("\n\nGame over! \nYour score was: %d\n", tetris_score);
       move.l    _tetris_score.L,-(A7)
       pea       @tetris_5.L
       jsr       _printf
       addq.w    #8,A7
; printf("\nPress any key to continue\n");
       pea       @tetris_6.L
       jsr       _printf
       addq.w    #4,A7
; while (1)
gameOver_1:
; {
; printw_x = 34;
       move.l    #34,(A3)
; printw_y = 20;
       move.l    #20,(A2)
; set_color(num);
       ext.w     D2
       ext.l     D2
       move.l    D2,-(A7)
       jsr       _set_color
       addq.w    #4,A7
; printw(game_over, "game over");
       pea       @tetris_2.L
       move.l    D3,-(A7)
       jsr       _printw
       addq.w    #8,A7
; printw_x = 34;
       move.l    #34,(A3)
; printw_y = 22;
       move.l    #22,(A2)
; printw(score_str, "score");
       pea       @tetris_7.L
       move.l    A4,-(A7)
       jsr       _printw
       addq.w    #8,A7
; if (kbhit())
       jsr       _kbhit
       tst.l     D0
       beq.s     gameOver_4
; {
; break;
       bra.s     gameOver_3
gameOver_4:
; }
; Wait300ms_here();
       jsr       _Wait300ms_here
; ++num;
       addq.b    #1,D2
; if (num > 7)
       cmp.b     #7,D2
       ble.s     gameOver_6
; {
; num = 1;
       moveq     #1,D2
gameOver_6:
       bra       gameOver_1
gameOver_3:
; }
; }
; set_vga_control_reg(0xA2);
       pea       162
       jsr       _set_vga_control_reg
       addq.w    #4,A7
       movem.l   (A7)+,D2/D3/A2/A3/A4
       unlk      A6
       rts
; }
; /////////////////////////////////////////////////////////////////////////////////////////////////////
; //
; //
; //                      end  functions to implement
; //
; //
; /////////////////////////////////////////////////////////////////////////////////////////////////////
; void delay_ms(int num_ms)
; {
       xdef      _delay_ms
_delay_ms:
       link      A6,#0
       movem.l   D2/D3,-(A7)
; int start_time;
; int current_time;
; start_time = clock();
       jsr       _clock
       move.l    D0,D2
; do
; {
delay_ms_1:
; current_time = clock();
       jsr       _clock
       move.l    D0,D3
; if (current_time < start_time)
       cmp.l     D2,D3
       bge.s     delay_ms_3
; { // handle wraparound
; num_ms = num_ms - (INT_MAX - start_time);
       move.l    #2147483647,D0
       sub.l     D2,D0
       sub.l     D0,8(A6)
; start_time = current_time;
       move.l    D3,D2
delay_ms_3:
       move.l    D3,D0
       sub.l     D2,D0
       cmp.l     8(A6),D0
       blt       delay_ms_1
       movem.l   (A7)+,D2/D3
       unlk      A6
       rts
; }
; } while ((current_time - start_time) < num_ms);
; }
; int tetris_rand()
; {
       xdef      _tetris_rand
_tetris_rand:
; return ((clock() >> 4) & 0xFFFF); // divide by 4 because clock increases by 10 every interrupt, ensure last digit is "random" too
       jsr       _clock
       asr.l     #4,D0
       and.l     #65535,D0
       rts
; }
; void CopyShape(Shape *shape, Shape *new_shape)
; {
       xdef      _CopyShape
_CopyShape:
       link      A6,#0
       movem.l   D2/D3/D4/D5,-(A7)
       move.l    12(A6),D2
       move.l    8(A6),D5
; int i;
; int j;
; new_shape->width = shape->width;
       move.l    D5,A0
       move.l    D2,A1
       move.l    16(A0),16(A1)
; new_shape->row = shape->row;
       move.l    D5,A0
       move.l    D2,A1
       move.l    20(A0),20(A1)
; new_shape->col = shape->col;
       move.l    D5,A0
       move.l    D2,A1
       move.l    24(A0),24(A1)
; for (i = 0; i < new_shape->width; i++)
       clr.l     D4
CopyShape_1:
       move.l    D2,A0
       cmp.l     16(A0),D4
       bge       CopyShape_3
; {
; for (j = 0; j < new_shape->width; j++)
       clr.l     D3
CopyShape_4:
       move.l    D2,A0
       cmp.l     16(A0),D3
       bge.s     CopyShape_6
; {
; new_shape->array[i][j] = shape->array[i][j];
       move.l    D5,A0
       move.l    D4,D0
       lsl.l     #2,D0
       add.l     D0,A0
       move.l    D2,A1
       move.l    D4,D0
       lsl.l     #2,D0
       add.l     D0,A1
       move.b    0(A0,D3.L),0(A1,D3.L)
       addq.l    #1,D3
       bra       CopyShape_4
CopyShape_6:
       addq.l    #1,D4
       bra       CopyShape_1
CopyShape_3:
       movem.l   (A7)+,D2/D3/D4/D5
       unlk      A6
       rts
; }
; }
; }
; int CheckPosition(Shape *shape)
; { // Check the position of the copied shape
       xdef      _CheckPosition
_CheckPosition:
       link      A6,#0
       movem.l   D2/D3/D4,-(A7)
       move.l    8(A6),D2
; int i, j;
; for (i = 0; i < shape->width; i++)
       clr.l     D4
CheckPosition_1:
       move.l    D2,A0
       cmp.l     16(A0),D4
       bge       CheckPosition_3
; {
; for (j = 0; j < shape->width; j++)
       clr.l     D3
CheckPosition_4:
       move.l    D2,A0
       cmp.l     16(A0),D3
       bge       CheckPosition_6
; {
; if ((shape->col + j < 0 || shape->col + j >= TETRIS_COLS || shape->row + i >= TETRIS_ROWS))
       move.l    D2,A0
       move.l    24(A0),D0
       add.l     D3,D0
       cmp.l     #0,D0
       blt.s     CheckPosition_9
       move.l    D2,A0
       move.l    24(A0),D0
       add.l     D3,D0
       cmp.l     #15,D0
       bge.s     CheckPosition_9
       move.l    D2,A0
       move.l    20(A0),D0
       add.l     D4,D0
       cmp.l     #20,D0
       blt.s     CheckPosition_7
CheckPosition_9:
; {							// Out of borders
; if (shape->array[i][j]) // but is it just a phantom?
       move.l    D2,A0
       move.l    D4,D0
       lsl.l     #2,D0
       add.l     D0,A0
       tst.b     0(A0,D3.L)
       beq.s     CheckPosition_10
; return FALSE;
       clr.l     D0
       bra       CheckPosition_12
CheckPosition_10:
       bra       CheckPosition_13
CheckPosition_7:
; }
; else if (Table[shape->row + i][shape->col + j] && shape->array[i][j])
       move.l    D2,A0
       move.l    20(A0),D0
       add.l     D4,D0
       muls      #15,D0
       lea       _Table.L,A0
       add.l     D0,A0
       move.l    D2,A1
       move.l    24(A1),D0
       add.l     D3,D0
       tst.b     0(A0,D0.L)
       beq.s     CheckPosition_13
       move.l    D2,A0
       move.l    D4,D0
       lsl.l     #2,D0
       add.l     D0,A0
       tst.b     0(A0,D3.L)
       beq.s     CheckPosition_13
; return FALSE;
       clr.l     D0
       bra.s     CheckPosition_12
CheckPosition_13:
       addq.l    #1,D3
       bra       CheckPosition_4
CheckPosition_6:
       addq.l    #1,D4
       bra       CheckPosition_1
CheckPosition_3:
; }
; }
; return TRUE;
       moveq     #1,D0
CheckPosition_12:
       movem.l   (A7)+,D2/D3/D4
       unlk      A6
       rts
; }
; void SetNewRandomShape()
; { // updates [current] with new shape
       xdef      _SetNewRandomShape
_SetNewRandomShape:
       move.l    A2,-(A7)
       lea       _current.L,A2
; currentColor = mod_bld(tetris_rand(), NUM_SHAPES);
       pea       7
       move.l    D0,-(A7)
       jsr       _tetris_rand
       move.l    D0,D1
       move.l    (A7)+,D0
       move.l    D1,-(A7)
       jsr       _mod_bld
       addq.w    #8,A7
       move.b    D0,_currentColor.L
; CopyShape(&ShapesArray[currentColor], &current);
       move.l    A2,-(A7)
       lea       _ShapesArray.L,A0
       move.b    _currentColor.L,D1
       ext.w     D1
       ext.l     D1
       muls      #28,D1
       add.l     D1,A0
       move.l    A0,-(A7)
       jsr       _CopyShape
       addq.w    #8,A7
; ++currentColor;
       addq.b    #1,_currentColor.L
; current.col = mod_bld(tetris_rand(), (TETRIS_COLS - current.width + 1));
       moveq     #15,D1
       ext.w     D1
       ext.l     D1
       sub.l     16(A2),D1
       addq.l    #1,D1
       move.l    D1,-(A7)
       move.l    D0,-(A7)
       jsr       _tetris_rand
       move.l    D0,D1
       move.l    (A7)+,D0
       move.l    D1,-(A7)
       jsr       _mod_bld
       addq.w    #8,A7
       move.l    D0,24(A2)
; current.row = 0;
       clr.l     20(A2)
; if (!CheckPosition(&current))
       move.l    A2,-(A7)
       jsr       _CheckPosition
       addq.w    #4,A7
       tst.l     D0
       bne.s     SetNewRandomShape_1
; {
; GameOn = FALSE;
       clr.b     _GameOn.L
SetNewRandomShape_1:
       move.l    (A7)+,A2
       rts
; // printf("Game on = false\n");
; }
; }
; void RotateShape(Shape *shape)
; { // rotates clockwise
       xdef      _RotateShape
_RotateShape:
       link      A6,#-28
       movem.l   D2/D3/D4/D5/D6,-(A7)
       move.l    8(A6),D6
; Shape temp;
; int i, j, k, width;
; CopyShape(shape, &temp);
       pea       -28(A6)
       move.l    D6,-(A7)
       jsr       _CopyShape
       addq.w    #8,A7
; width = shape->width;
       move.l    D6,A0
       move.l    16(A0),D4
; for (i = 0; i < width; i++)
       clr.l     D2
RotateShape_1:
       cmp.l     D4,D2
       bge       RotateShape_3
; {
; for (j = 0, k = width - 1; j < width; j++, k--)
       clr.l     D3
       move.l    D4,D0
       subq.l    #1,D0
       move.l    D0,D5
RotateShape_4:
       cmp.l     D4,D3
       bge.s     RotateShape_6
; {
; shape->array[i][j] = temp.array[k][i];
       lea       -28(A6),A0
       move.l    D5,D0
       lsl.l     #2,D0
       add.l     D0,A0
       move.l    D6,A1
       move.l    D2,D0
       lsl.l     #2,D0
       add.l     D0,A1
       move.b    0(A0,D2.L),0(A1,D3.L)
       addq.l    #1,D3
       subq.l    #1,D5
       bra       RotateShape_4
RotateShape_6:
       addq.l    #1,D2
       bra       RotateShape_1
RotateShape_3:
       movem.l   (A7)+,D2/D3/D4/D5/D6
       unlk      A6
       rts
; }
; }
; }
; void WriteToTable()
; {
       xdef      _WriteToTable
_WriteToTable:
       movem.l   D2/D3/A2,-(A7)
       lea       _current.L,A2
; int i, j;
; for (i = 0; i < current.width; i++)
       clr.l     D3
WriteToTable_1:
       cmp.l     16(A2),D3
       bge       WriteToTable_3
; {
; for (j = 0; j < current.width; j++)
       clr.l     D2
WriteToTable_4:
       cmp.l     16(A2),D2
       bge       WriteToTable_6
; {
; if (current.array[i][j])
       move.l    D3,D0
       lsl.l     #2,D0
       lea       0(A2,D0.L),A0
       tst.b     0(A0,D2.L)
       beq.s     WriteToTable_7
; Table[current.row + i][current.col + j] = current.array[i][j];
       move.l    D3,D0
       lsl.l     #2,D0
       lea       0(A2,D0.L),A0
       move.l    20(A2),D0
       add.l     D3,D0
       muls      #15,D0
       lea       _Table.L,A1
       add.l     D0,A1
       move.l    24(A2),D0
       add.l     D2,D0
       move.b    0(A0,D2.L),0(A1,D0.L)
WriteToTable_7:
       addq.l    #1,D2
       bra       WriteToTable_4
WriteToTable_6:
       addq.l    #1,D3
       bra       WriteToTable_1
WriteToTable_3:
       movem.l   (A7)+,D2/D3/A2
       rts
; }
; }
; }
; void RemoveFullRowsAndUpdateScore()
; {
       xdef      _RemoveFullRowsAndUpdateScore
_RemoveFullRowsAndUpdateScore:
       link      A6,#-4
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3,-(A7)
       lea       _Table.L,A2
       lea       _Tetris_Speed.L,A3
; int i, j, sum, count = 0;
       moveq     #0,D7
; int l, k;
; int compliment_to_say;
; for (i = 0; i < TETRIS_ROWS; i++)
       clr.l     D4
RemoveFullRowsAndUpdateScore_1:
       cmp.l     #20,D4
       bge       RemoveFullRowsAndUpdateScore_3
; {
; sum = 0;
       clr.l     D6
; for (j = 0; j < TETRIS_COLS; j++)
       clr.l     D5
RemoveFullRowsAndUpdateScore_4:
       cmp.l     #15,D5
       bge.s     RemoveFullRowsAndUpdateScore_6
; {
; sum += Table[i][j];
       move.l    D4,D0
       muls      #15,D0
       lea       0(A2,D0.L),A0
       move.b    0(A0,D5.L),D0
       ext.w     D0
       ext.l     D0
       add.l     D0,D6
       addq.l    #1,D5
       bra       RemoveFullRowsAndUpdateScore_4
RemoveFullRowsAndUpdateScore_6:
; }
; if (sum == TETRIS_COLS)
       cmp.l     #15,D6
       bne       RemoveFullRowsAndUpdateScore_7
; {
; count++;
       addq.l    #1,D7
; for (k = i; k >= 1; k--)
       move.l    D4,D3
RemoveFullRowsAndUpdateScore_9:
       cmp.l     #1,D3
       blt.s     RemoveFullRowsAndUpdateScore_11
; for (l = 0; l < TETRIS_COLS; l++)
       clr.l     D2
RemoveFullRowsAndUpdateScore_12:
       cmp.l     #15,D2
       bge.s     RemoveFullRowsAndUpdateScore_14
; Table[k][l] = Table[k - 1][l];
       move.l    D3,D0
       subq.l    #1,D0
       muls      #15,D0
       lea       0(A2,D0.L),A0
       move.l    D3,D0
       muls      #15,D0
       lea       0(A2,D0.L),A1
       move.b    0(A0,D2.L),0(A1,D2.L)
       addq.l    #1,D2
       bra       RemoveFullRowsAndUpdateScore_12
RemoveFullRowsAndUpdateScore_14:
       subq.l    #1,D3
       bra       RemoveFullRowsAndUpdateScore_9
RemoveFullRowsAndUpdateScore_11:
; for (l = 0; l < TETRIS_COLS; l++)
       clr.l     D2
RemoveFullRowsAndUpdateScore_15:
       cmp.l     #15,D2
       bge.s     RemoveFullRowsAndUpdateScore_17
; Table[k][l] = 0;
       move.l    D3,D0
       muls      #15,D0
       lea       0(A2,D0.L),A0
       clr.b     0(A0,D2.L)
       addq.l    #1,D2
       bra       RemoveFullRowsAndUpdateScore_15
RemoveFullRowsAndUpdateScore_17:
; compliment_to_say = mod_bld(tetris_rand(), NUM_LINE_SUCCESS_MESSAGES);
       pea       3
       move.l    D0,-(A7)
       jsr       _tetris_rand
       move.l    D0,D1
       move.l    (A7)+,D0
       move.l    D1,-(A7)
       jsr       _mod_bld
       addq.w    #8,A7
       move.l    D0,-4(A6)
; switch (compliment_to_say)
       move.l    -4(A6),D0
       cmp.l     #1,D0
       beq.s     RemoveFullRowsAndUpdateScore_21
       bgt.s     RemoveFullRowsAndUpdateScore_24
       tst.l     D0
       beq.s     RemoveFullRowsAndUpdateScore_20
       bra.s     RemoveFullRowsAndUpdateScore_18
RemoveFullRowsAndUpdateScore_24:
       cmp.l     #2,D0
       beq.s     RemoveFullRowsAndUpdateScore_22
       bra.s     RemoveFullRowsAndUpdateScore_18
RemoveFullRowsAndUpdateScore_20:
; {
; case 0:
; say_awesome();
       jsr       _say_awesome
; break;
       bra.s     RemoveFullRowsAndUpdateScore_19
RemoveFullRowsAndUpdateScore_21:
; case 1:
; say_cool();
       jsr       _say_cool
; break;
       bra.s     RemoveFullRowsAndUpdateScore_19
RemoveFullRowsAndUpdateScore_22:
; case 2:
; say_yeah();
       jsr       _say_yeah
; break;
       bra.s     RemoveFullRowsAndUpdateScore_19
RemoveFullRowsAndUpdateScore_18:
; default:
; say_yeah();
       jsr       _say_yeah
; break;
RemoveFullRowsAndUpdateScore_19:
; }
; Tetris_Speed.speed = Tetris_Speed.speed + Tetris_Speed.speed_increase;
       move.l    (A3),D0
       add.l     4(A3),D0
       move.l    D0,(A3)
RemoveFullRowsAndUpdateScore_7:
       addq.l    #1,D4
       bra       RemoveFullRowsAndUpdateScore_1
RemoveFullRowsAndUpdateScore_3:
; }
; }
; tetris_score += 100 * count;
       move.l    D7,-(A7)
       pea       100
       jsr       LMUL
       move.l    (A7),D0
       addq.w    #8,A7
       add.l     D0,_tetris_score.L
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3
       unlk      A6
       rts
; }
; void PrintTable()
; {
       xdef      _PrintTable
_PrintTable:
       link      A6,#-428
       movem.l   D2/D3/A2/A3/A4,-(A7)
       lea       _current.L,A2
       lea       _printw.L,A3
       lea       -300(A6),A4
; int i, j;
; char score_str[128];
; char Buffer[TETRIS_ROWS][TETRIS_COLS];
; printw_x = 0;
       clr.l     _printw_x.L
; printw_y = 0;
       clr.l     _printw_y.L
; for (i = 0; i < TETRIS_ROWS; i++)
       clr.l     D2
PrintTable_1:
       cmp.l     #20,D2
       bge.s     PrintTable_3
; {
; for (j = 0; j < TETRIS_COLS; j++)
       clr.l     D3
PrintTable_4:
       cmp.l     #15,D3
       bge.s     PrintTable_6
; {
; Buffer[i][j] = 0;
       move.l    D2,D0
       muls      #15,D0
       lea       0(A4,D0.L),A0
       clr.b     0(A0,D3.L)
       addq.l    #1,D3
       bra       PrintTable_4
PrintTable_6:
       addq.l    #1,D2
       bra       PrintTable_1
PrintTable_3:
; }
; }
; for (i = 0; i < current.width; i++)
       clr.l     D2
PrintTable_7:
       cmp.l     16(A2),D2
       bge       PrintTable_9
; {
; for (j = 0; j < current.width; j++)
       clr.l     D3
PrintTable_10:
       cmp.l     16(A2),D3
       bge       PrintTable_12
; {
; if (current.array[i][j])
       move.l    D2,D0
       lsl.l     #2,D0
       lea       0(A2,D0.L),A0
       tst.b     0(A0,D3.L)
       beq       PrintTable_13
; {
; Buffer[current.row + i][current.col + j] = current.array[i][j];
       move.l    D2,D0
       lsl.l     #2,D0
       lea       0(A2,D0.L),A0
       move.l    20(A2),D0
       add.l     D2,D0
       muls      #15,D0
       lea       0(A4,D0.L),A1
       move.l    24(A2),D0
       add.l     D3,D0
       move.b    0(A0,D3.L),0(A1,D0.L)
; TableColor[current.row + i][current.col + j] = currentColor;
       move.l    20(A2),D0
       add.l     D2,D0
       muls      #15,D0
       lea       _TableColor.L,A0
       add.l     D0,A0
       move.l    24(A2),D0
       add.l     D3,D0
       move.b    _currentColor.L,0(A0,D0.L)
PrintTable_13:
       addq.l    #1,D3
       bra       PrintTable_10
PrintTable_12:
       addq.l    #1,D2
       bra       PrintTable_7
PrintTable_9:
; }
; }
; }
; go_to_top_corner();
       jsr       _go_to_top_corner
; printw("\n\n\n", "initial_newline");
       pea       @tetris_9.L
       pea       @tetris_8.L
       jsr       (A3)
       addq.w    #8,A7
; for (i = 0; i < TETRIS_COLS - 9; i++)
       clr.l     D2
PrintTable_15:
       cmp.l     #6,D2
       bge.s     PrintTable_17
; {
; printw(" ", "space");
       pea       @tetris_11.L
       pea       @tetris_10.L
       jsr       (A3)
       addq.w    #8,A7
       addq.l    #1,D2
       bra       PrintTable_15
PrintTable_17:
; }
; printw("CPEN412 Tetris\n", "title");
       pea       @tetris_13.L
       pea       @tetris_12.L
       jsr       (A3)
       addq.w    #8,A7
; for (i = 0; i < TETRIS_ROWS; i++)
       clr.l     D2
PrintTable_18:
       cmp.l     #20,D2
       bge       PrintTable_20
; {
; for (j = 0; j < TETRIS_COLS; j++)
       clr.l     D3
PrintTable_21:
       cmp.l     #15,D3
       bge       PrintTable_23
; {
; if (Table[i][j] + Buffer[i][j])
       move.l    D2,D0
       muls      #15,D0
       lea       _Table.L,A0
       add.l     D0,A0
       move.b    0(A0,D3.L),D0
       move.l    D2,D1
       muls      #15,D1
       lea       0(A4,D1.L),A0
       add.b     0(A0,D3.L),D0
       beq.s     PrintTable_24
; {
; printwColor("#", TableColor[i][j], "table#");
       pea       @tetris_15.L
       move.l    D2,D1
       muls      #15,D1
       lea       _TableColor.L,A0
       add.l     D1,A0
       move.b    0(A0,D3.L),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       pea       @tetris_14.L
       jsr       _printwColor
       add.w     #12,A7
       bra.s     PrintTable_25
PrintTable_24:
; }
; else
; {
; printw(".", "table.");
       pea       @tetris_17.L
       pea       @tetris_16.L
       jsr       (A3)
       addq.w    #8,A7
PrintTable_25:
       addq.l    #1,D3
       bra       PrintTable_21
PrintTable_23:
; }
; // printw(" ","space2");
; }
; printw("\n", "newline1");
       pea       @tetris_19.L
       pea       @tetris_18.L
       jsr       (A3)
       addq.w    #8,A7
       addq.l    #1,D2
       bra       PrintTable_18
PrintTable_20:
; }
; sprintf(score_str, "\nScore: %d\n", tetris_score);
       move.l    _tetris_score.L,-(A7)
       pea       @tetris_20.L
       pea       -428(A6)
       jsr       _sprintf
       add.w     #12,A7
; printw(score_str, "scoreprint");
       pea       @tetris_21.L
       pea       -428(A6)
       jsr       (A3)
       addq.w    #8,A7
       movem.l   (A7)+,D2/D3/A2/A3/A4
       unlk      A6
       rts
; }
; void ManipulateCurrent(int action)
; {
       xdef      _ManipulateCurrent
_ManipulateCurrent:
       link      A6,#-28
       movem.l   A2/A3/A4,-(A7)
       lea       -28(A6),A2
       lea       _current.L,A3
       lea       _CheckPosition.L,A4
; Shape temp;
; CopyShape(&current, &temp);
       move.l    A2,-(A7)
       move.l    A3,-(A7)
       jsr       _CopyShape
       addq.w    #8,A7
; switch (action)
       move.l    8(A6),D0
       cmp.l     #115,D0
       beq.s     ManipulateCurrent_3
       bgt.s     ManipulateCurrent_7
       cmp.l     #100,D0
       beq       ManipulateCurrent_4
       bgt       ManipulateCurrent_2
       cmp.l     #97,D0
       beq       ManipulateCurrent_5
       bra       ManipulateCurrent_2
ManipulateCurrent_7:
       cmp.l     #119,D0
       beq       ManipulateCurrent_6
       bra       ManipulateCurrent_2
ManipulateCurrent_3:
; {
; case 's':
; temp.row++; // move down
       move.l    A2,D0
       add.l     #20,D0
       move.l    D0,A0
       addq.l    #1,(A0)
; if (CheckPosition(&temp))
       move.l    A2,-(A7)
       jsr       (A4)
       addq.w    #4,A7
       tst.l     D0
       beq.s     ManipulateCurrent_8
; {
; current.row++;
       move.l    A3,D0
       add.l     #20,D0
       move.l    D0,A0
       addq.l    #1,(A0)
       bra.s     ManipulateCurrent_9
ManipulateCurrent_8:
; }
; else
; {
; WriteToTable();
       jsr       _WriteToTable
; RemoveFullRowsAndUpdateScore();
       jsr       _RemoveFullRowsAndUpdateScore
; SetNewRandomShape();
       jsr       _SetNewRandomShape
ManipulateCurrent_9:
; }
; break;
       bra       ManipulateCurrent_2
ManipulateCurrent_4:
; case 'd':
; temp.col++; // move right
       move.l    A2,D0
       add.l     #24,D0
       move.l    D0,A0
       addq.l    #1,(A0)
; if (CheckPosition(&temp))
       move.l    A2,-(A7)
       jsr       (A4)
       addq.w    #4,A7
       tst.l     D0
       beq.s     ManipulateCurrent_10
; current.col++;
       move.l    A3,D0
       add.l     #24,D0
       move.l    D0,A0
       addq.l    #1,(A0)
ManipulateCurrent_10:
; break;
       bra       ManipulateCurrent_2
ManipulateCurrent_5:
; case 'a':
; temp.col--; // move left
       move.l    A2,D0
       add.l     #24,D0
       move.l    D0,A0
       subq.l    #1,(A0)
; if (CheckPosition(&temp))
       move.l    A2,-(A7)
       jsr       (A4)
       addq.w    #4,A7
       tst.l     D0
       beq.s     ManipulateCurrent_12
; current.col--;
       move.l    A3,D0
       add.l     #24,D0
       move.l    D0,A0
       subq.l    #1,(A0)
ManipulateCurrent_12:
; break;
       bra.s     ManipulateCurrent_2
ManipulateCurrent_6:
; case 'w':
; RotateShape(&temp); // rotate clockwise
       move.l    A2,-(A7)
       jsr       _RotateShape
       addq.w    #4,A7
; if (CheckPosition(&temp))
       move.l    A2,-(A7)
       jsr       (A4)
       addq.w    #4,A7
       tst.l     D0
       beq.s     ManipulateCurrent_14
; RotateShape(&current);
       move.l    A3,-(A7)
       jsr       _RotateShape
       addq.w    #4,A7
ManipulateCurrent_14:
; break;
ManipulateCurrent_2:
; }
; PrintTable();
       jsr       _PrintTable
       movem.l   (A7)+,A2/A3/A4
       unlk      A6
       rts
; }
; void initTetris_Speed()
; {
       xdef      _initTetris_Speed
_initTetris_Speed:
; Tetris_Speed.speed = INITIAL_TETRIS_SPEED;
       move.l    #2,_Tetris_Speed.L
; Tetris_Speed.speed_increase = TETRIS_SPEED_INCREASE;
       move.l    #1,_Tetris_Speed+4.L
       rts
; }
; void tetris_mainloop()
; {
       xdef      _tetris_mainloop
_tetris_mainloop:
       link      A6,#-4
       move.l    D2,-(A7)
; int current_time;
; int got_game_over;
; while (1)
tetris_mainloop_1:
; {
; current_time = clock();
       jsr       _clock
       move.l    D0,D2
; if (kbhit())
       jsr       _kbhit
       tst.l     D0
       beq.s     tetris_mainloop_6
; {
; ManipulateCurrent(getch());
       move.l    D0,-(A7)
       jsr       _getch
       move.l    D0,D1
       move.l    (A7)+,D0
       move.l    D1,-(A7)
       jsr       _ManipulateCurrent
       addq.w    #4,A7
; if (!GameOn)
       tst.b     _GameOn.L
       bne.s     tetris_mainloop_6
; {
; break;
       bra       tetris_mainloop_3
tetris_mainloop_6:
; }
; }
; if (current_time >= ((MILLISECONDS_PER_SEC / Tetris_Speed.speed) + tetris_timer))
       pea       1000
       move.l    _Tetris_Speed.L,-(A7)
       jsr       LDIV
       move.l    (A7),D0
       addq.w    #8,A7
       add.l     _tetris_timer.L,D0
       cmp.l     D0,D2
       blt.s     tetris_mainloop_8
; {
; ManipulateCurrent('s');
       pea       115
       jsr       _ManipulateCurrent
       addq.w    #4,A7
; if (!GameOn)
       tst.b     _GameOn.L
       bne.s     tetris_mainloop_10
; {
; break;
       bra.s     tetris_mainloop_3
tetris_mainloop_10:
; }
; tetris_timer = current_time;
       move.l    D2,_tetris_timer.L
tetris_mainloop_8:
       bra       tetris_mainloop_1
tetris_mainloop_3:
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; }
; }
; // void test(){
; // 	printf("Testing\n");
; // 	while (1){
; // 		octlAddress = 0xF3;
; // 		octlAddress1 = 0xE2;
; // 	}
; // }
; // void testSound(){
; //     say_awesome();
; // 	Wait250ms_here();
; // 	say_cool();
; // 	Wait250ms_here();
; // 	say_yeah();
; // 	Wait250ms_here();
; // 	say_game_over();
; // 	Wait250ms_here();
; // }
; int tetris_main()
; {
       xdef      _tetris_main
_tetris_main:
       link      A6,#-132
       movem.l   D2/D3/A2/A3/A4,-(A7)
       lea       _ShapesArray.L,A2
       lea       _printf.L,A3
       lea       _Table.L,A4
; int i, j;
; int test1;
; char score_str[128];
; // while(1){
; // 	testSound();
; // }
; // test();
; timer_count = 0;
       clr.l     _timer_count.L
; printw_x = 0;
       clr.l     _printw_x.L
; printw_y = 0;
       clr.l     _printw_y.L
; GameOn = TRUE;
       move.b    #1,_GameOn.L
; InstallExceptionHandler(Timer_ISR, 30);
       pea       30
       pea       _Timer_ISR.L
       jsr       _InstallExceptionHandler
       addq.w    #8,A7
; Timer1Data = 0x25; // 100 ms
       move.b    #37,4194352
; Timer1Control = 3; // enable timer, periodic mode
       move.b    #3,4194354
; // InstallExceptionHandler(Timer_ISR, 29);
; // InstallExceptionHandler(Timer_ISR, 28);
; // InstallExceptionHandler(Timer_ISR, 27);
; // InstallExceptionHandler(Timer_ISR, 26);
; // InstallExceptionHandler(Timer_ISR, 25);
; octl = OCTL_TETRIS_DEFAULT;
       move.b    #162,_octl.L
; octlAddress = octl;
       move.b    _octl.L,-16580608
; for (j = 0; j < TETRIS_COLS; j++)
       clr.l     D2
tetris_main_1:
       cmp.l     #15,D2
       bge       tetris_main_3
; {
; Table[0][j] = 2; // default color
       move.b    #2,0(A4,D2.L)
; for (i = 0; i < TETRIS_ROWS; i++)
       clr.l     D3
tetris_main_4:
       cmp.l     #20,D3
       bge.s     tetris_main_6
; {
; Table[i][j] = 0;
       move.l    D3,D0
       muls      #15,D0
       lea       0(A4,D0.L),A0
       clr.b     0(A0,D2.L)
; TableColor[i + 1][j] = 2; // default color
       move.l    D3,D0
       addq.l    #1,D0
       muls      #15,D0
       lea       _TableColor.L,A0
       add.l     D0,A0
       move.b    #2,0(A0,D2.L)
       addq.l    #1,D3
       bra       tetris_main_4
tetris_main_6:
       addq.l    #1,D2
       bra       tetris_main_1
tetris_main_3:
; }
; }
; // S shape
; ShapesArray[0].array[0][0] = 0;
       clr.b     (A2)
; ShapesArray[0].array[0][1] = 1;
       move.b    #1,1(A2)
; ShapesArray[0].array[0][2] = 1;
       move.b    #1,2(A2)
; ShapesArray[0].array[1][0] = 1;
       move.b    #1,4(A2)
; ShapesArray[0].array[1][1] = 1;
       move.b    #1,4+1(A2)
; ShapesArray[0].array[1][2] = 0;
       clr.b     4+2(A2)
; ShapesArray[0].array[2][0] = 0;
       clr.b     8(A2)
; ShapesArray[0].array[2][1] = 0;
       clr.b     8+1(A2)
; ShapesArray[0].array[2][2] = 0;
       clr.b     8+2(A2)
; ShapesArray[0].width = 3;
       move.l    #3,16(A2)
; // Z shape
; ShapesArray[1].array[0][0] = 1;
       move.b    #1,28(A2)
; ShapesArray[1].array[0][1] = 1;
       move.b    #1,28+1(A2)
; ShapesArray[1].array[0][2] = 0;
       clr.b     28+2(A2)
; ShapesArray[1].array[1][0] = 0;
       clr.b     28+4(A2)
; ShapesArray[1].array[1][1] = 1;
       move.b    #1,28+4+1(A2)
; ShapesArray[1].array[1][2] = 1;
       move.b    #1,28+4+2(A2)
; ShapesArray[1].array[2][0] = 0;
       clr.b     28+8(A2)
; ShapesArray[1].array[2][1] = 0;
       clr.b     28+8+1(A2)
; ShapesArray[1].array[2][2] = 0;
       clr.b     28+8+2(A2)
; ShapesArray[1].width = 3;
       move.l    #3,44(A2)
; // T shape
; ShapesArray[2].array[0][0] = 0;
       clr.b     56(A2)
; ShapesArray[2].array[0][1] = 1;
       move.b    #1,56+1(A2)
; ShapesArray[2].array[0][2] = 0;
       clr.b     56+2(A2)
; ShapesArray[2].array[1][0] = 1;
       move.b    #1,56+4(A2)
; ShapesArray[2].array[1][1] = 1;
       move.b    #1,56+4+1(A2)
; ShapesArray[2].array[1][2] = 1;
       move.b    #1,56+4+2(A2)
; ShapesArray[2].array[2][0] = 0;
       clr.b     56+8(A2)
; ShapesArray[2].array[2][1] = 0;
       clr.b     56+8+1(A2)
; ShapesArray[2].array[2][2] = 0;
       clr.b     56+8+2(A2)
; ShapesArray[2].width = 3;
       move.l    #3,72(A2)
; // L shape
; ShapesArray[3].array[0][0] = 0;
       clr.b     84(A2)
; ShapesArray[3].array[0][1] = 0;
       clr.b     84+1(A2)
; ShapesArray[3].array[0][2] = 1;
       move.b    #1,84+2(A2)
; ShapesArray[3].array[1][0] = 1;
       move.b    #1,84+4(A2)
; ShapesArray[3].array[1][1] = 1;
       move.b    #1,84+4+1(A2)
; ShapesArray[3].array[1][2] = 1;
       move.b    #1,84+4+2(A2)
; ShapesArray[3].array[2][0] = 0;
       clr.b     84+8(A2)
; ShapesArray[3].array[2][1] = 0;
       clr.b     84+8+1(A2)
; ShapesArray[3].array[2][2] = 0;
       clr.b     84+8+2(A2)
; ShapesArray[3].width = 3;
       move.l    #3,100(A2)
; // flipped L shape
; ShapesArray[4].array[0][0] = 1;
       move.b    #1,112(A2)
; ShapesArray[4].array[0][1] = 0;
       clr.b     112+1(A2)
; ShapesArray[4].array[0][2] = 0;
       clr.b     112+2(A2)
; ShapesArray[4].array[1][0] = 1;
       move.b    #1,112+4(A2)
; ShapesArray[4].array[1][1] = 1;
       move.b    #1,112+4+1(A2)
; ShapesArray[4].array[1][2] = 1;
       move.b    #1,112+4+2(A2)
; ShapesArray[4].array[2][0] = 0;
       clr.b     112+8(A2)
; ShapesArray[4].array[2][1] = 0;
       clr.b     112+8+1(A2)
; ShapesArray[4].array[2][2] = 0;
       clr.b     112+8+2(A2)
; ShapesArray[4].width = 3;
       move.l    #3,128(A2)
; // square shape
; ShapesArray[5].array[0][0] = 1;
       move.b    #1,140(A2)
; ShapesArray[5].array[0][1] = 1;
       move.b    #1,140+1(A2)
; ShapesArray[5].array[1][0] = 1;
       move.b    #1,140+4(A2)
; ShapesArray[5].array[1][1] = 1;
       move.b    #1,140+4+1(A2)
; ShapesArray[5].width = 2;
       move.l    #2,156(A2)
; // long bar shape
; ShapesArray[6].array[0][0] = 0;
       clr.b     168(A2)
; ShapesArray[6].array[0][1] = 0;
       clr.b     168+1(A2)
; ShapesArray[6].array[0][2] = 0;
       clr.b     168+2(A2)
; ShapesArray[6].array[0][3] = 0;
       clr.b     168+3(A2)
; ShapesArray[6].array[1][0] = 1;
       move.b    #1,168+4(A2)
; ShapesArray[6].array[1][1] = 1;
       move.b    #1,168+4+1(A2)
; ShapesArray[6].array[1][2] = 1;
       move.b    #1,168+4+2(A2)
; ShapesArray[6].array[1][3] = 1;
       move.b    #1,168+4+3(A2)
; ShapesArray[6].array[2][0] = 0;
       clr.b     168+8(A2)
; ShapesArray[6].array[2][1] = 0;
       clr.b     168+8+1(A2)
; ShapesArray[6].array[2][2] = 0;
       clr.b     168+8+2(A2)
; ShapesArray[6].array[2][3] = 0;
       clr.b     168+8+3(A2)
; ShapesArray[6].array[3][0] = 0;
       clr.b     168+12(A2)
; ShapesArray[6].array[3][1] = 0;
       clr.b     168+12+1(A2)
; ShapesArray[6].array[3][2] = 0;
       clr.b     168+12+2(A2)
; ShapesArray[6].array[3][3] = 0;
       clr.b     168+12+3(A2)
; ShapesArray[6].width = 4;
       move.l    #4,184(A2)
; set_color(OCTL_TETRIS_DEFAULT);
       pea       162
       jsr       _set_color
       addq.w    #4,A7
; set_vga_control_reg(OCTL_TETRIS_DEFAULT);
       pea       162
       jsr       _set_vga_control_reg
       addq.w    #4,A7
; tetris_score = 0;
       clr.l     _tetris_score.L
; initTetris_Speed();
       jsr       _initTetris_Speed
; clear_screen();
       jsr       _clear_screen
; tetris_timer = clock();
       jsr       _clock
       move.l    D0,_tetris_timer.L
; SetNewRandomShape();
       jsr       _SetNewRandomShape
; PrintTable();
       jsr       _PrintTable
; tetris_mainloop();
       jsr       _tetris_mainloop
; gameOver();
       jsr       _gameOver
; for (i = 0; i < TETRIS_ROWS; i++)
       clr.l     D3
tetris_main_7:
       cmp.l     #20,D3
       bge       tetris_main_9
; {
; for (j = 0; j < TETRIS_COLS; j++)
       clr.l     D2
tetris_main_10:
       cmp.l     #15,D2
       bge.s     tetris_main_12
; {
; if (Table[i][j])
       move.l    D3,D0
       muls      #15,D0
       lea       0(A4,D0.L),A0
       tst.b     0(A0,D2.L)
       beq.s     tetris_main_13
; {
; printf("#");
       pea       @tetris_14.L
       jsr       (A3)
       addq.w    #4,A7
       bra.s     tetris_main_14
tetris_main_13:
; }
; else
; {
; printf(".");
       pea       @tetris_16.L
       jsr       (A3)
       addq.w    #4,A7
tetris_main_14:
       addq.l    #1,D2
       bra       tetris_main_10
tetris_main_12:
; }
; }
; printf("\n");
       pea       @tetris_18.L
       jsr       (A3)
       addq.w    #4,A7
       addq.l    #1,D3
       bra       tetris_main_7
tetris_main_9:
; }
; printf("\nGame over!\n");
       pea       @tetris_22.L
       jsr       (A3)
       addq.w    #4,A7
; sprintf(score_str, "\nScore: %d\n", tetris_score);
       move.l    _tetris_score.L,-(A7)
       pea       @tetris_20.L
       pea       -128(A6)
       jsr       _sprintf
       add.w     #12,A7
; printf(score_str);
       pea       -128(A6)
       jsr       (A3)
       addq.w    #4,A7
; return 0;
       clr.l     D0
       movem.l   (A7)+,D2/D3/A2/A3/A4
       unlk      A6
       rts
; }
       section   const
@tetris_1:
       dc.b      37,115,10,0
@tetris_2:
       dc.b      103,97,109,101,32,111,118,101,114,0
@tetris_3:
       dc.b      32,71,97,109,101,32,111,118,101,114,33,32,0
@tetris_4:
       dc.b      32,83,99,111,114,101,58,32,37,100,32,0
@tetris_5:
       dc.b      10,10,71,97,109,101,32,111,118,101,114,33,32
       dc.b      10,89,111,117,114,32,115,99,111,114,101,32,119
       dc.b      97,115,58,32,37,100,10,0
@tetris_6:
       dc.b      10,80,114,101,115,115,32,97,110,121,32,107,101
       dc.b      121,32,116,111,32,99,111,110,116,105,110,117
       dc.b      101,10,0
@tetris_7:
       dc.b      115,99,111,114,101,0
@tetris_8:
       dc.b      10,10,10,0
@tetris_9:
       dc.b      105,110,105,116,105,97,108,95,110,101,119,108
       dc.b      105,110,101,0
@tetris_10:
       dc.b      32,0
@tetris_11:
       dc.b      115,112,97,99,101,0
@tetris_12:
       dc.b      67,80,69,78,52,49,50,32,84,101,116,114,105,115
       dc.b      10,0
@tetris_13:
       dc.b      116,105,116,108,101,0
@tetris_14:
       dc.b      35,0
@tetris_15:
       dc.b      116,97,98,108,101,35,0
@tetris_16:
       dc.b      46,0
@tetris_17:
       dc.b      116,97,98,108,101,46,0
@tetris_18:
       dc.b      10,0
@tetris_19:
       dc.b      110,101,119,108,105,110,101,49,0
@tetris_20:
       dc.b      10,83,99,111,114,101,58,32,37,100,10,0
@tetris_21:
       dc.b      115,99,111,114,101,112,114,105,110,116,0
@tetris_22:
       dc.b      10,71,97,109,101,32,111,118,101,114,33,10,0
       section   bss
       xdef      _Table
_Table:
       ds.b      300
       xdef      _TableColor
_TableColor:
       ds.b      315
       xdef      _currentColor
_currentColor:
       ds.b      1
       xdef      _tetris_score
_tetris_score:
       ds.b      4
       xdef      _GameOn
_GameOn:
       ds.b      1
       xdef      _tetris_timer
_tetris_timer:
       ds.b      4
       xdef      _octl
_octl:
       ds.b      1
       xdef      _current
_current:
       ds.b      28
       xdef      _ShapesArray
_ShapesArray:
       ds.b      196
       xdef      _Tetris_Speed
_Tetris_Speed:
       ds.b      8
       xdef      _printw_x
_printw_x:
       ds.b      4
       xdef      _printw_y
_printw_y:
       ds.b      4
       xdef      _cx
_cx:
       ds.b      1
       xdef      _cy
_cy:
       ds.b      1
       xdef      _timer_count
_timer_count:
       ds.b      4
       xref      _talkphonemeVV
       xref      LDIV
       xref      LMUL
       xref      _talkphonemeKK3
       xref      _talkphonemeGG1
       xref      _talkphonemeOW
       xref      _endword
       xref      _talkphonemeAO
       xref      _talkphonemeSS
       xref      _talkphonemeER2
       xref      _kbhit
       xref      _getch
       xref      _sprintf
       xref      _talkphonemeEL
       xref      _talkphonemeEH
       xref      _talkphonemeUH
       xref      _FlushKeyboard
       xref      _talkphonemeYY2
       xref      _InstallExceptionHandler
       xref      _talkphonemeMM
       xref      _talkphonemeEY
       xref      _talkphonemeAA
       xref      _printf
