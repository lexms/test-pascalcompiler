// This program is develop and Compile using VS Code and Free Pascal Compiler version 3.0.4 [2017/10/06] for i386

{
    10116370 Alexander M S
    10116371 Archy Renaldy P N
}

program testpascal(input, output);

uses dos, crt;

const
{Keywords List}
    keywords: array [0..27] of string[10]=
    (
        'AND',
        'BEGIN',
        'CONST',
        'DIV',
        'ELSE',
        'END',
        'IF',
        'MOD',
        'NOT',
        'OR',
        'PROGRAM',
        'THEN',
        'VAR',
        'LABEL',
        'TYPE',
        'GOTO',
        'WHILE',
        'DO',
        'FOR',
        'CASE',
        'REPEAT',
        'UNTIL',
        'WITH',
        'DOWNTO',
        'OF',
        'FILE',
        'SET',
        'RECORD'
    );



{Keywords Table}
Table_kw: array [0..27] of string[20] =
    (
        'T_AND',
        'T_BEGIN',
        'T_CONST',
        'T_DIV',
        'T_ELSE',
        'T_END',
        'T_IF',
        'T_MOD',
        'T_NOT',
        'T_OR',
        'T_PRG',
        'T_THEN',
        'T_VAR',
        'T_LABEL',
        'T_TYPE',
        'T_GOTO',
        'T_WHILE',
        'T_DO',
        'T_FOR',
        'T_CASE',
        'T_REPEAT',
        'T_UNTIL',
        'T_WITH',
        'T_DOWNTO',
        'T_OF',
        'T_FILE',
        'T_SET',
        'T_RECORD'
    );

type
    {Symbol Table Structure}
    isiTSimbol = RECORD
                    nama    : string[10];
                    objek   : string[10];
                    tipe    : string[7];
                    ref     : integer;
                end;

var
    filein,                 {nama file keluaran}
    fileout :string[79];    {nama file masukan}
    TextIn,                 {var file masukan}
    TextOut :text;          {var file keluaran}
    simb    :text;          {var file table display}
    {rConst  :text;}          {var file table RConst}
    token   :string[20];
    k       :string[255]; {penampung 1 baris string input}
    strID   :string[255]; {string berisi identifier}
    angka_r :real;        {nilai konversi string menjadi real}
    angka_i :integer;     {nilai konversi string menjadi integer}

    i,                      {counter karakter tiap kali membaca 1 line darifile}
    CountSim,               {counter table simbol}
    CountRConst :integer;   {counter table RConst}

    no_temp     :integer;   {counter untuk variabel "TEMP"}
    TSimbol     :array[0..100] of isiTSimbol; {table simbol}

    jmlerror    :integer;
    errorBool   :boolean;
    countLine   :integer;
    repairBool  :boolean;

function cek_key(var ind:integer; w:string):boolean;
{cek strID apakah keyword atau identifier biasa}
var
    sama:boolean;
begin
    ind:=0;
    sama:=false;

    while (ind<=23) and (not sama) do
        if w=keywords[ind] THEN
            sama:=true
        else inc(ind);

    if sama then cek_key := true
        else cek_key := false;
end;{function}

function StrToInt(strID:string):boolean;
{cek apakah string tersebut bisa di konversi menjadi integer}
var
    code, value:integer;
    s:string[255];

begin
    Val(strID,value,code);
    Str(value,s);

    {bandingkan apakah hasil Val sama dengan sebelumnya}
    if (s=strID) and (value<=32767) then
        StrToInt:=true
    else
        StrToInt:=false
end;{function StrToInt}

function StrToReal(strID:string):boolean;
{cek apakah string tersebut bisa di konversi menjadi real}

var
    value: extended;
    code:integer;
begin
    Val(strID,value,code);
    if(value>1.7E+38) or (value<2.9E-39) then
        StrToReal := false
    else
        StrToReal := true;
    
end;{function StrToReal}

procedure input_file;
{untuk mendapatkan nama file input untuk di-Scan, dan nama file output hasil dari Scan}
var
    s:PathStr;
    j:char;
    i:integer;

begin
    repeat
        clrscr;
        write('Masukkan nama file yang akan diParse, e.g:tes1.pas :');
        readln(filein);
        s:= FSearch(filein,GetEnv('PATH'));
        if s=''then
        begin
            writeln(filein,' tidak ada dalam direktori !');
            writeln;
            write('Ingin memakai standard file (tes1.pas)?  (Y/N)');
            j:= readkey;
            if upcase(j)='Y' then 
                filein := 'tes1.pas'
            else filein := '';
        end;
    until (filein<>'');    


    writeln; writeln;
    fileout:='2KOMENTAR.PAS';
    if fileout='' then
    begin
        i:= Pos(s,filein);
        fileout:=copy(filein,1,i);
        fileout:=fileout+'OUT';
    end;

end;{procedure input_file}

procedure Scan; forward;
procedure STATEMENT; forward;

procedure ReportError (no:integer);
begin
    write(TextOut,'Line',countLine,' : ');
    if no in [11] then
        write(TextOut,strID,'--> Warning (',no,'): ')
    else    
        write(TextOut,strID,'--> Error (',no,'): ');
    
    case no of
        1   : write(TextOut,'"PROGRAM" expected');
        2   : write(TextOut,'"BEGIN" expected');
        3   : write(TextOut,'"THEN" expected');
        6   : write(TextOut,'"END" expected');
        8   : write(TextOut,'"OF" expected');
        9   : write(TextOut,'"(" expected');
        10  : write(TextOut,'")" expected');
        11  : write(TextOut,'";" expected');
        12  : write(TextOut,'":" expected');
        13  : write(TextOut,'"=" expected');
        14  : write(TextOut,'":=" expected');
        15  : write(TextOut,'"." expected');
        16  : write(TextOut,'Number expected');
        17  : write(TextOut,'Constant Identifier expected');

        19  : write(TextOut,'"*)" expected');
        20  : write(TextOut,'"}" expected');
        21  : write(TextOut,'Identifier expected');

        22  : write(TextOut,'Error in expression');
        23  : write(TextOut,'Duplicate Identifier');
        24  : write(TextOut,'Error in statement');
        25  : write(TextOut,'Unexpected end of file');
        26  : write(TextOut,'Real Out Of Range');
        27  : write(TextOut,'Integer Out Of Range');
        28  : write(TextOut,'Syntax Error');
        29  : write(TextOut,'Unknown Identifier');
        30  : write(TextOut,'Unknown Symbol');
        
        53  : write(TextOut,'Until expected');
        54  : write(TextOut,'DO expected');
        55  : write(TextOut,'TO/DOWNTO expected');

    end;
    writeln(TextOut);
end;{procedure ReportError}

procedure RecoveryError;
begin
    jmlerror:=jmlerror+1;
    if jmlerror<=25 then
    begin
        if (not eof(TextIn)) and not(token='T_TITIK') then
        begin
            repeat
                Scan;
            until token='T_TIKOM';
            Scan;
            Statement;
        end;
    end
    else
    begin
        close(TextIn);
        close(TextOut);
        writeln;
        writeln('Silahkan lihat file ',fileout,' ... dan file 1TABEL.pas');
        halt(1);
    end;
end;{procedure RecoveryError}

procedure RepairError(no: integer);
var
    tempToken : string[20];
begin
    repairBool:=true;
    case no of
        11: begin
            tempToken:=token;
            token:='T_TIKOM';
            token:=tempToken;
        end;
    end;
end;

procedure error(no: integer);
{menentukan jenis error pada saat parsing atau Scanning (error nomor 30) program masukan}
begin
    if (token<>'T_INT') and (token<>'T_REAL') then
    begin
        errorBool :=true;
        ReportError(no);
        if no in [11] then
            RepairError(no)
        else
            RecoveryError;
    end;
end;{procedure error}

procedure simbol; forward;

procedure Scan;
{men-Scan file masukan, dan mengelompokannya ke dalam token-token}

const
    digit   = ['0'..'9'];
    letter  = ['A'..'Z','a'..'z'];

var
    j, code : integer;
    index   : integer;
    w       : string[10];
    keluar  : boolean;

begin
    if repairBool then
        repairBool:= false
    else
    begin
        if i<=length(k) then
        begin
            while k[i]=' ' do inc(i);

            case k[i] of
                'A'..'Z','a'..'z':
                    begin
                        strID := k[i];
                        inc(i);
                        while (( (k[i] in letter) or (k[i] in digit) ) and (i<=length(k)) ) do
                        begin
                            strID:=strID+k[i];
                            inc(i);
                        end;

                        if length(strID)<10 then
                        begin
                            {diduga keywords, ubah dulu menjadi huruf besar}
                            w:= strID;
                            for j := 1 to length(strID) do
                                w[j]:=upcase(strID[j]);

                            {cek dalam tabel keywords}
                            if cek_key(index,w)=false then
                                token := 'T_ID'
                            else
                                token := Table_kw[index];                            
                        end
                        else
                            token := 'T_ID';
                    end;{'A'..'Z','a'..'z'}
                    
                '0'..'9':
                    begin
                        strID := k[i];
                        inc(i);
                        while (k[i] in digit) and (i<=length(k)) do
                        begin
                            strID := strID+k[i];
                            inc(i);
                        end;

                        if i>length(k) then 
                        begin
                            token := 'T_INT';
                            {ubah menjadi bilangan integer}
                            if StrToInt(strID) then
                            begin
                                val(strID, angka_i, code);
                                token:= 'T_INT';
                            end
                            else
                                error(27);
                            exit;
                        end;

                        {cek apakah integer atau real}

                        case k[i] of
                        '.' : 
                            begin
                                if k[i+1]='.'then
                                    error(16)
                                else
                                begin
                                    strID:=strID+k[i];
                                    inc(i);
                                    if (k[i] in digit) then
                                    begin
                                        while (k[i] in digit) and (i<=length(k)) do
                                        begin
                                            strID:=strID+k[i];
                                            inc(i);                    
                                        end;

                                        if(k[i]<>'e') and (k[i]<>'E') then
                                            {ubah menjadi bilangan real}
                                            if StrToReal(strID) then begin
                                                val(strID,angka_r,code);
                                                token:='T_REAL';
                                            end
                                            else
                                                error(26)
                                        else
                                        begin
                                            strID :=strID+k[i];
                                            inc(i);
                                            if ((k[i]='-') or (k[i]='+')) and (i<=length(k)) then
                                            begin
                                                strID:=strID+k[i];
                                                inc(i);
                                            end;
                                            if (k[i] in digit) and (i<=length(k)) then
                                            begin
                                                while (k[i] in digit) and (i<=length(k)) do
                                                begin
                                                    strID:= strID + k[i];
                                                    inc(i);
                                                end;
                                                {ubah menjadi bilangan real}
                                                if StrToReal(strID) then
                                                begin
                                                    val(strID,angka_r,code);
                                                    token:='T_REAL';
                                                end
                                                else
                                                    error(26);
                                            end{if (k[i] in digit) and (i<=length(k))}
                                            else
                                                error(28);
                                        end;{else (k[i]<>'e') and (k[i]<>'E')}
                                    end{if (k[i] in digit)}
                                    else
                                        error(28);
                                end;{else k[i+1]='.'}
                            end;{.}
                        'E','e':
                            begin
                                strID:=strID+k[i];
                                inc(i);

                                if(k[i]='-') or (k[i]='+') then
                                begin
                                    strID := strID + k[i];
                                    inc(i);
                                end;
                                if(k[i] in digit) then
                                begin
                                    while (k[i] in digit) and (i<=length(k)) do
                                    begin
                                        strID:=strID+k[i];
                                        inc(i);
                                    end;
                                    {ubah menjadi bilangan real}
                                    if StrToReal(strID) then
                                    begin
                                        val(strID,angka_r,code);
                                        token:='T_REAL';
                                    end
                                    else
                                        error(26); 
                                end
                                else
                                    error(28); 
                            end{'E','e':}
                            else
                            begin
                                if length(strID)>5 then
                                    error(27)
                                else
                                begin
                                    {ubah menjadi bilangan integer}
                                    if StrToInt(strID) then
                                    begin
                                        val(strID,angka_i,code);
                                        token:='T_INT';
                                    end
                                    else
                                        error(27);
                                end;
                            end;{else 'E','e':}
                        end;{case k[i] of}
                    end;{'0'..'9'}
                '+':begin
                        strID:=k[i];
                        token:='T_PLUS';
                        inc(i);
                    end;
                '-':begin
                        strID:=k[i];
                        token:='T_MINUS';
                        inc(i);
                    end;
                '*':begin
                        strID:=k[i];
                        token:='T_KALI';
                        inc(i);
                    end;

                '/':begin
                        strID:=k[i];
                        token:='T_BAGI';
                        inc(i);
                    end;

                '=':begin
                        strID:=k[i];
                        token:='T_EQUAL';
                        inc(i);
                    end;

                '<':begin
                        strID:=k[i];
                        inc(i);
                        case k[i] of 
                        '>' : begin
                                strID:=strID + k[i];
                                token:='T_NOTEQ';
                                inc(i);
                            end;
                        '=' : begin
                                strID:=strID + k[i];
                                token:='T_LESSEQ';
                                inc(i);
                            end
                            else begin
                                    token:='T_LESS';
                                end;
                        end;{endcase}
                    end;{end '<'}

                '>':begin
                        strID := k[i];
                        inc(i);
                        if k[i] = '=' then
                        begin
                            strID:=strID + k[i];
                            token:='T_GREATEREQ';
                            inc(i);
                        end
                        else
                            token:= 'T_GREATER';
                    end;{end '>'}
                
                ':':begin
                        strID := k[i];
                        inc(i);
                        if k[i] = '=' then
                        begin
                            strID:=strID + k[i];
                            token:='T_ASG';
                            inc(i);
                        end
                        else
                            token:= 'T_TTK2';
                    end;           
                ',':begin
                        strID:= k[i];
                        token:='T_KOMA';
                        inc(i);
                    end;
                '.':begin
                        token:='T_TITIK';
                        inc(i);
                    end;
                ';':begin
                        strID:= k[i];
                        token:='T_TIKOM';
                        inc(i);
                    end;
                '(':begin
                        strID:= k[i];
                        inc(i);
                        if k[i]='*' then
                        begin
                            inc(i);
                            keluar:= false;
                            repeat
                                if i=length(k) then
                                begin
                                    readln(TextIn,k);
                                    Inc(countLine);
                                    i:=1;
                                end;
                                if (k[i]='*') and (k[i+1]=')') then
                                begin
                                    i := i + 2 ;
                                    keluar := true;
                                end
                                else
                                    inc(i);
                            until(keluar) or (i>length(k));

                            if not keluar then
                                {kurang tanda akhir komentar}
                                error(19)
                            else
                                Scan;
                        end
                        else
                            token:= 'T_BUKA';
                    end;
                ')':begin
                        strID:=k[i];
                        token:='T_TUTUP';
                        inc(i);
                    end;
                '{':begin
                        strID := k[i];
                        inc(i);
                        keluar := false;
                        repeat
                            if (k[i]='}') and (i<=length(k)) then
                            begin
                                keluar:=true;
                                inc(i);
                            end
                            else
                                if i>length(k) then
                                begin
                                    if not eof(TextIn) then
                                    begin
                                        readln(TextIn,k);
                                        inc(countLine);
                                        {writeln(TextOut,k);}
                                        writeln(k);
                                    end;
                                    i:=1;
                                end
                                else
                                    inc(i);
                        until (keluar) or eof(TextIn);
                        {kalau komentar benar, dibuang, kalau tidak beri pesan}
                        if not keluar then
                            error(20)
                        else
                            Scan;
                    end{end kurung krawal}
            else 
                begin
                    strID:=k[i];
                    error(30);
                end;
            end;{case k[i] of}
        end{if i<=length(k)}
        else
            begin
                if not eof(TextIn) then
                begin
                    readln(TextIn,k);
                    inc(countLine);
                    writeln(k);
                    {writeln(TextOut,k);}
                    i:=1;
                    Scan;
                end
                else
                    error(25);
            end;
    end;{if repairBool}
end;{procedure Scan}

procedure Init_Sim;
{inisialisasi awal tabel simbol}
begin
    TSimbol[0].nama:='';
    TSimbol[0].objek:='';
    TSimbol[0].tipe:='';
    TSimbol[0].ref:=0;

    TSimbol[1].nama:='INTEGER';
    TSimbol[1].objek:='TYPE';
    TSimbol[1].tipe:='INTEGER';
    TSimbol[1].ref:=0;

    TSimbol[2].nama:='REAL';
    TSimbol[2].objek:='TYPE';
    TSimbol[2].tipe:='REAL';
    TSimbol[2].ref:=0;

    TSimbol[3].nama:='CHAR';
    TSimbol[3].objek:='TYPE';
    TSimbol[3].tipe:='CHAR';
    TSimbol[3].ref:=0;

    TSimbol[4].nama:='BOOLEAN';
    TSimbol[4].objek:='TYPE';
    TSimbol[4].tipe:='BOOLEAN';
    TSimbol[4].ref:=0;

    TSimbol[5].nama:='TRUE';
    TSimbol[5].objek:='CONST';
    TSimbol[5].tipe:='BOOLEAN';
    TSimbol[5].ref:=1;

    TSimbol[6].nama:='FALSE';
    TSimbol[6].objek:='CONST';
    TSimbol[6].tipe:='BOOLEAN';
    TSimbol[6].ref:=0;

    TSimbol[7].nama:='MAXINT';
    TSimbol[7].objek:='CONST';
    TSimbol[7].tipe:='INTEGER';
    TSimbol[7].ref:=32767;
    CountSim:=7;    
end;{procedure Init_Sim}

procedure InputTab(elemen:isiTSimbol);
{memasukkan identifier ke dalam Tabel Simbol}
begin
    inc(CountSim);
    TSimbol[CountSim]:=elemen;
end;{procedure InputTab}

function InTSimbol(var elemen : isiTSimbol; var ind:integer):boolean;
{cek apakah identifier tsb sudah dideklarasikan (ada dalam Tabel Simbol), mengembalikan nilai indexnya bila ada di Tabel Simbol}
var
    ada : boolean;
    count:integer;

begin
    {ubah dulu nama elemennya jadi uppercase}
    for count:=1 to length(elemen.nama) do
        elemen.nama[count]:= UpCase(elemen.nama[count]);
    
    ada:= false;
    count:=1;

    {cari di daftar tabel simbol}
    while (count<=CountSim) and (not ada) do
    begin
        if(TSimbol[count].nama=elemen.nama) then
            ada:=true
        else
            inc(count);
    end;

    ind:=count;

    if ada then 
        InTSimbol := true
    else 
        InTSimbol:=false;
end;{function InTSimbol}

procedure Un_const;
var
    elemen  :isiTSimbol;
    ind     :integer;
    s       :string[5];
begin
    if(token='T_INT') or (token='T_REAL') then
    begin
        {unsigned number}

        {beri nomor temp}
        inc(no_temp);
        str(no_temp,s);

        elemen.nama:='TEMP_' + s;
        elemen.objek:='CONST';

        if token='T_INT' then
        begin
            elemen.tipe:='INTEGER';
            elemen.ref:=angka_i;
        end
        else begin
            inc(CountRConst);
            elemen.tipe:='REAL';
            elemen.ref:=CountRConst;
        end;

        InputTab(elemen);
        Scan;
    end
    else begin
        {constant identifier}
        elemen.nama:=strID;
        if InTSimbol(elemen,ind) then
        begin
            if TSimbol[ind].objek = 'CONST' then
            begin
                Scan;
            end
            else
                error(17);    
        end;
    end;
end;{procedure Un_const}

procedure CONSTANT(var elemen: isiTSimbol);
var
    ind:integer;
    simpan:char;
    {count:integer;}
    el:isiTSimbol;
begin
    if(token='T_PLUS') or (token='T_MINUS') then
    begin
        simpan:=strID[1];
        Scan;
    end;

    if(token='T_INT') then
    begin
        if simpan='-'then
            angka_i := angka_i * (-1);
        
        elemen.tipe:='INTEGER';
        elemen.ref:=angka_i;
        Scan;
    end
    else if token='T_REAL' then
        begin
            if simpan='-' then
                angka_r := angka_r * (-1);
            
            inc(CountRConst);
            elemen.tipe:='REAL';
            elemen.ref:=CountRConst;
            Scan;
        end
        else begin
            {constant identifier}
            {cari di tabel simbol, dengan nama identifier tsb, lihat tipenya, set ref-nya}
            el.nama:=strID;

            if InTSimbol(el,ind) then
            begin
                if TSimbol[ind].objek='CONST' then
                begin
                    elemen.tipe:=TSimbol[ind].tipe;
                    elemen.ref:=TSimbol[ind].ref;
                end
                else    
                    error(17);
            end
            else
                error(29);
            Scan;
        end;
end;{procedure CONSTANT}

procedure SimpleType(var elemen: isiTSimbol);
var
    ind:integer;
    el:isiTSimbol;
begin
    el.nama:=strID;

    if InTSimbol(el,ind) then
    begin
        if TSimbol[ind].objek='TYPE' then
        begin
            elemen.tipe:=TSimbol[ind].nama;
            Scan;
        end
        else
            error(18);
    end
    else
        error(21);
end;{procedure SimpleType}

procedure TIPE(var elemen: isiTSimbol);
var
    Sudah:boolean;
begin
    Sudah:=false;
    if token = 'T_FILE' then
    begin
        Sudah:=true;
        Scan;
        if token<>'T_OF' then
            error(8)
        else
        begin
            Scan;
            tipe(elemen);
        end;
    end;

    if token='T_SET' then
    begin
        Sudah:=true;
        Scan;
        if token<>'T_OF' then
            error(8)
        else
            begin
                Scan;
                SimpleType(elemen);
            end;
    end;
    if not(Sudah) then
        SimpleType(elemen);
end;{procedure TIPE}

procedure VARIABEL;
var
    ind{,t}:integer;
    elemen: isiTSimbol;
    {count:integer;}
begin
    elemen.nama :=strID;

    if InTSimbol(elemen,ind) then
    begin
        if TSimbol[ind].objek ='VAR' then
        begin
            Scan;
        end
        else
            error(24);
    end
    else
        error(29)
end;{procedure VARIABEL}

procedure EXPRESSION; forward;

procedure FACTOR;
var
    elemen:isiTSimbol;
    ind:integer;
    {count:integer;}

begin
    if token='T_BUKA' then
    begin
        Scan;
        EXPRESSION;

        if token='T_TUTUP' then
            Scan
        else
            error(10);
    end;{'('}

        if token='T_NOT' then
        begin
            Scan;
            FACTOR;
        end; {not}

            elemen.nama:=strID;

            if InTSimbol(elemen,ind) then
                if TSimbol[ind].objek='VAR' then
                    VARIABEL
                else Un_const
            else
                error(29);
end;{procedure FACTOR}

procedure TERM;
var
    savestrID :string[3];
    count:integer;
begin
    FACTOR;
    while   (token='T_KALI') or (token='T_BAGI') or
            (token='T_DIV') or (token='T_MOD') or
            (token='T_AND') do
    begin
        for count:=1 to length(strID) do
            strID[count]:=upcase(strID[count]);
        savestrID:=strID;
        Scan;
        FACTOR;
    end;{while}
end;{procedure TERM}

procedure Simple_exp;
var
    savestrID:string[2];
    count:integer;
begin
    if (token='T_PLUS') or (token = 'T_MINUS') then
    begin
        savestrID:=strID;
        Scan;
    end;
    TERM;
    while (token='T_PLUS') or (token='T_MINUS') or (token='T_OR') do
    begin
        for count:=1 to length(strID) do 
            strID[count] := UpCase(strID[count]);
        savestrID:=strID;
        Scan;
        TERM;
    end;    
end;{procedure Simple_exp}

procedure EXPRESSION;
var
    savestrID:string[2];
    count:integer;
begin
    Simple_exp;
    if  (token='T_EQUAL') or (token='T_LESS') or
        (token='T_GREATER') or (token='T_NOTEQ') or
        (token='T_LESSEQ') or (token='T_GREATEREQ') then
    begin
        for count:=1 to length(strID) do
            strID[count]:=upcase(strID[count]);
        savestrID:=strID;
        Scan;
        Simple_exp;
    end;
end;{procedure EXPRESSION}

procedure STATEMENT;
var
    {ulang   :boolean;}
    elemen  :isiTSimbol;
    ind     :integer;
begin
    if token='T_ID' then
    begin
        VARIABEL;
        if token ='T_ASG' then
        begin
            Scan;
            EXPRESSION;
        end
        else
            error(14);
    end;{VARIABEL}
    if token='T_BEGIN' then
    begin
        Scan;
        STATEMENT;
        while token='T_TIKOM' do
        begin
            Scan;
            STATEMENT;
        end;
        if token = 'T_END' then
            Scan
        else
            error(6);
    end;{begin}

    if token='T_IF' then
    begin
        Scan;
        EXPRESSION;
        if token='T_THEN' then
        begin
            Scan;
            STATEMENT;
            if token='T_ELSE' then
            begin
                Scan;
                STATEMENT;
            end;
        end
        else
            error(3);
    end;{if}

    if token='T_WHILE' then
    begin
        Scan;
        EXPRESSION;
        if token<>'T_DO' then
            error(54)
        else
        begin
            Scan;
            STATEMENT;
        end;
    end;{while}

    if token='T_REPEAT' then
    begin
        Scan;
        STATEMENT;
        while token ='T_TIKOM' do
        begin
            Scan;
            STATEMENT;
        end;

        if token<>'T_UNTIL' then
            error(53)
        else
        begin
            Scan;
            EXPRESSION;
        end;
    end;{repeat}

    if token='T_FOR' then
    begin
        Scan;
        elemen.nama:=strID;
        if InTSimbol(elemen,ind) then
        begin
            if TSimbol[ind].objek='VAR' then
            begin
                Scan;
            end
            else
                error(24);
        end
        else
            error(29);
        
        if token<>'T_ASSIGN' then
            error(14)
        else
        begin
            Scan;
            EXPRESSION;
            if not ((token='T_TO') or (token='T_DOWNTO')) then
                error(55)
            else
            begin
                Scan;
                EXPRESSION;
                if token<>'T_DO' then
                    error(54)
                else
                begin
                    Scan;
                    STATEMENT;
                end;
            end;
        end;
    end;{for}

    if token='T_WITH' then
    begin
        Scan;
        VARIABEL;
        while token ='T_KOMA' do
        begin
            Scan;
            VARIABEL;
        end;
        STATEMENT;
    end;{with}

    if token='T_GOTO' then
    begin
        Scan;
        if token<>'T_INT' then
            error(16)
        else
            Scan;
    end;
    
end;{procedure STATEMENT}

procedure BLOCK;
label awal;

var 
    simpan: string[20];
    elemen:isiTSimbol;
    count:integer;
    ind{, i}:integer;
    tabvar:array[1..100] of string[8];
    c:integer;
    el:isiTSimbol;
begin
    simpan:='';
    if token='T_LABEL' then
    begin
        Scan;
        if token<>'T_INT' then
            error(16)
        else
            begin
                Scan;
                while token='T_KOMA' do
                begin
                    Scan;
                    if token<>'T_INT' then
                        error(16)
                    else
                        Scan;
                end;
                if token<>'T_TIKOM' then
                    error(11);
                Scan;    
            end{else token<>'T_INT'}
    end;{if token='T_LABEL'}

    if token='T_CONST' then
    begin
        Scan;
        if token<>'T_ID' then
            error(21)
        else
        begin
            while token = 'T_ID' do
            begin
                elemen.nama:=strID;
                if InTSimbol(elemen,ind) then   
                    error(23);
                simpan:=strID;
                Scan;
                if token='T_EQUAL' then
                begin
                    Scan;
                    if strID=simpan then error(22);
                    elemen.objek:='CONST';
                    elemen.ref:=CountRConst;
                    CONSTANT(elemen);
                    if token<>'T_TIKOM' then
                        error(11);
                    InputTab(elemen);
                    Scan;
                end
                else
                    error(13);
            end;{while}
        end;
    end;{const}

    if Token='T_TYPE' then
    begin
        Scan;
        if token<>'T_ID' then
            error(21)
        else
        begin
            Scan;
            if token<>'T_EQUAL' then
                error(13)
            else
            begin
                Scan;
                TIPE(elemen);
            end;
        end;
    end;{type}

    if token='T_VAR' then
    begin
        c:=1;
        Scan;
        if token<>'T_ID' then
            error(21)
        else
        begin
            while token='T_ID' do
            begin
                for count:=1 to length(strID) do
                    strID[count] := UpCase(strID[count]);
                {simpan semua variabel identifier dalam tabel variabel}

                tabvar[c]:=strID;
                inc(c);
                simpan:=token;
                Scan;
                if token='T_KOMA' then
                begin
                    simpan:=token;
                    Scan;
                end
                else
                begin
                    simpan:=token;
                    if token='T_TTK2' then
                    begin
                        Scan;
                        simpan:=token;
                        TIPE(elemen);

                        simpan:=token;

                        if token<>'T_TIKOM' then
                            error(11);
                            {masukkan semua variabel identifier yang ada dalam tabvar ke dalam tabel simbol}

                            elemen.objek:='VAR';
                            elemen.ref:=0;
                            for count:=1 to (c-1) do
                            begin
                                elemen.nama:=tabvar[count];
                                InputTab(elemen);
                            end;
                            Scan;
                            simpan:=token;
                            c:=1;  
                    end
                    else
                        error(12);
                end{else token='T_KOMA'}
            end;{while}
            if(simpan='T_KOMA') and (token<>'T_ID') then
                error(21);
        end;{else token<>'T_ID'}
    end;{var}

    awal:
        if token='T_PROC' then
        begin
            Scan;
            if token<>'T_ID' then
                error(21)
            else
            begin
                Scan;
                if token <>'T_TIKOM' then
                    error(11);
                    Scan;
                    BLOCK;
                    if token<>'T_TIKOM' then
                        error(11);
                    Scan;
                    goto awal;
            end;
        end;

        if token ='T_FUNC' then
        begin
            Scan;
            if token<>'T_ID' then
                error(21)
            else
                begin
                    Scan;
                    if token<>'T_TTK2' then
                        error(1)
                    else
                    begin
                        Scan;
                        {TYPE IDENTIFIER CHECK}

                        el.nama:=strID;
                        if InTSimbol(el,ind) then
                        begin
                            if TSimbol[ind].objek='TYPE' then
                            begin
                                elemen.tipe:=TSimbol[ind].nama;
                                Scan;
                            end
                            else
                                error(18);
                        end
                        else
                            error(21);
                        
                        if token<>'T_TIKOM' then
                            error(11);
                            Scan;
                            BLOCK;
                            if token<>'T_TIKOM' then
                                error(11)
                            else
                                begin
                                    Scan;
                                    goto awal;
                                end;

                    end;{else token<>'T_TTK2'}
                end;{else token<>'T_ID'}
        end;

        if token='T_BEGIN' then
        begin
            Scan;
            STATEMENT;
            while token='T_TIKOM' do
            begin
                Scan;
                STATEMENT;
            end;

            if token='T_ID' then
            begin
                error(11);
                Scan;
            end;

            if token<>'T_END' then
                error(6)
            else
                Scan;
        end{begin}
        else
            error(2);

end;{procedure BLOCK}

procedure PRG;
begin
    if token='T_PRG' then
    begin
        Scan;
        if token='T_ID' then
        begin
            Scan;
            if token='T_BUKA' then
            begin
                Scan;
                if token='T_ID' then
                begin
                    Scan;
                    while token='T_KOMA' do
                    begin
                        Scan;
                        if token='T_ID' then
                            Scan
                        else
                            error(21);
                    end;{while}
                    if token='T_TUTUP' then
                    begin
                        Scan;
                        if token<>'T_TIKOM' then
                            error(11);
                            Scan;
                            BLOCK;
                            if token<>'T_TITIK' then
                                error(15);
                    end
                    else 
                        error(10);
                end
                else
                    error(21);
            end
            else 
                error(9);
        end
        else
            error(21);
    end{if token='T_PRG'}
    else
        error(1);

end;{procedure PRG}

procedure Parse;
begin
    if eof(TextIn) then
    begin
        writeln('File Kosong');
        close(TextOut);
    end
    else begin
        jmlerror:=0;
        errorBool:=false;
        countLine:=0;
        repairBool:=false;
        readln(TextIn, k);
        inc(countLine);
        writeln(k);

        i:=1;
        Scan;
        PRG;
        writeln(TextOut);
        writeln;

        if errorBool then
        begin
            writeln('Silahkan lihat file ',fileout,' ... dan file 1TABEL.pas')
        end
        else begin
            writeln(TextOut, 'Sukses ...');
            writeln('Parsing Sukses !!!');
        end;
        close(TextIn);
        close(TextOut);
    end;
end;{procedure Parse}

procedure simbol;
{memuat isi tabel simbol ke dalam file yang bernama SIMBOL}
var
    count:integer;
begin
    writeln(simb,'Isi tabel Simbol :');
    writeln(simb);
    write(simb,'Index':5);
    write(simb,'Nama':12);
    write(simb,'Objek':12);
    write(simb,'Tipe':12);
    write(simb,'Ref':12);

    for count:=0 to CountSim do
    begin
        write(simb,count:5);
        write(simb,TSimbol[count].nama:12);
        write(simb,TSimbol[count].objek:12);
        write(simb,TSimbol[count].tipe:12);
        writeln(simb,TSimbol[count].ref:12);
    end;
    close(simb);
end;{procedure simbol}

{======================== MAIN PROGRAM ========================}
begin
    input_file;
    Init_Sim;               {initialize symbol table}
    CountRConst:=0;         {initialize counter RConst table}
    no_temp:=0;             {initialize counter temp}
    clrscr;
    assign(TextIn,filein);
    reset(TextIn);

    assign(TextOut,fileout);
    rewrite(TextOut);

    assign(simb,'1TABEL.pas');
    rewrite(simb);

    writeln(TextOut, 'Hasil parse untuk file "',filein,'"');
    writeln(TextOut);
    writeln(TextOut);
    parse;
    simbol;
    readln;
end.