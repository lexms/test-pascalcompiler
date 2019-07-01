program Tes1(input,output);
var
    A,B,C,D,E:integer;

BEGIN
    A:=D*C+B/E;
    A:=2;
    B:=3;
    C:=4;
    D:=5;
    E:=6;
    
end.

//D C * B E / +

{
    *,  D,  C, T1,
    /,  B,  E, T2,
    +, T1, T2,  A,
    
    LDA D
    MUL C
    STO T1
    LDA B
    DIV E
    STO T2
    LDA T1
    ADD T2
    STO A


}