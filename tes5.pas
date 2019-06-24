program Cetakfibonacci;
{I.S.:User memasukkan jumlah(N) angka fibonacci yang ingin dicetak}
{F.S.: Mencetak N kali fibonacci 0 1 1 2 3 5 8 }
uses crt;
var
  n,i:integer;

function fibonacci(n:integer): integer;
begin
     if(N=1)
       then
          fibonacci:= 0
       else
          if(N=2)
            then
                fibonacci:= 1
            else
                fibonacci := fibonacci(N-1)+fibonacci(N-2);
end;

begin
     writeln('Masukkan Jumlah angka fibonacci yang ingin dicetak');readln(N);
     for i := 1 to N do
         write(fibonacci(i),' ');
     readkey;
end.
