#include <stdio.h>
#include <string.h>

/**
 * プログラミング用フォント Ricty で C を書く
 *
 * - 環境は GNU Emacs 23 on Ubuntu
 * - Emacs のカラーテーマは Lethe (一部改変)
 * - 予約語、コメント、文字列などはボールドフェース
 */
int main(int argc, char *argv[])
{
    char ascii_letter;          /* ASCII 文字 */
    char unicode_letter[3];     /* ユニコード文字 */
    int  count = 0;             /* 文字カウンタ */

    /* 印字可能な区画の ASCII 文字 */
    for (ascii_letter =  ' ';
         ascii_letter <= '~';
         ascii_letter++, count++)
    {
        if (count >= 40) { printf("\n"); count = 0; } /* 40 文字で改行 */
        printf("%c", ascii_letter);
    }

    /* ひらがな全部 */
    for (strcpy(unicode_letter, "ぁ");
         strcmp(unicode_letter, "ん") <= 0;
         unicode_letter[2]++, count += 2)
    {
        if (unicode_letter[2] == -64)
        {
            unicode_letter[1]++;
            unicode_letter[2] = -128;
        }
        if (count >= 40) { printf("\n"); count = 0; } /* 40 文字で改行 */
        printf("%s", unicode_letter);
    }

    /* Ricty で手を入れたグリフ */
    printf("　，．：；–―\n");

    return 0;
}
