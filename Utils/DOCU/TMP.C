//F fooi
//S Synopsis for foo
//D Description for foo
//P the first arg
void fooi(char *a)
{
    *a++;
}
//F fooh
//S Synopsis for foo
//D Description for foo
//P the first arg
void fooh(char *a)
{
    *a++;
}
//F foog
//S Synopsis for foo
//D Description for foo
//P the first arg
void foog(char *a)
{
    *a++;
}
//F foof
//S Synopsis for foo
//D Description for foo
//P the first arg
void foof(char *a)
{
    *a++;
}
//F fooe
//S Synopsis for foo
//D Description for foo
//P the first arg
void fooe(char *a)
{
    *a++;
}
//F food
//S Synopsis for foo
//D Description for foo
//P the first arg
void food(char *a)
{
    *a++;
}
//F fooc
//S Synopsis for foo
//D Description for foo
//P the first arg
void fooc(char *a)
{
    *a++;
}
//F foob
//S Synopsis for foo
//D Description for foo
//P the first arg
void foob(char *a)
{
    *a++;
}
//F fooa
//S Synopsis for foo
//D Description for foo
//P the first arg
void fooa(char *a)
{
    *a++;
}

//F bar
//S Synopsis for bar
//D Description for bar
//R the ret value
char bar(void)
{
    return 'A';
}

//F main
//S Synopsis for main
//D Description for main
//R the ret value
int main(void)
{
    char a;
    a=bar();
    foo(&a);
    return 1;
}
