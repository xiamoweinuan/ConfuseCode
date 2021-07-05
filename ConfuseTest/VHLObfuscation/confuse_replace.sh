#!/usr/bin/env bash

#生成宏的前缀
MOTHOD_Macor="fbzh"



TABLENAME=symbols
SYMBOL_DB_FILE="symbols"
#方法
STRING_SYMBOL_FILE="$PROJECT_DIR/VHLObfuscation/func.list"
#单词
WordLIST_FILE="$PROJECT_DIR/VHLObfuscation/words_replace.list"

CONFUSE_FILE="$PROJECT_DIR"

HEAD_FILE="$PROJECT_DIR/VHLObfuscation/codeObfuscation_replace.h"

export LC_CTYPE=C

createTable()
{
echo "create table $TABLENAME(src text, des text);" | sqlite3 $SYMBOL_DB_FILE
}

insertValue()
{
echo "insert into $TABLENAME values('$1' ,'$2');" | sqlite3 $SYMBOL_DB_FILE
}

query()
{
echo "select * from $TABLENAME where src='$1';" | sqlite3 $SYMBOL_DB_FILE
}

ramdomString()
{
totalWordsNum=`wc -l $WordLIST_FILE | awk '{print $1}'`
idx=1
#NUM为要生成的随机单词的个数
NUM=5
declare -i num
declare -i randNum
ratio=1
firstIndex=0
words=""
while [ "$idx" -le "$NUM" ]
do
a=$RANDOM
num=$(( $a*$ratio ))
randNum=`expr $num%$totalWordsNum+1`
word=`sed -n "$randNum"p $WordLIST_FILE`
firstWord=${word:0:1}
if [ $idx != 1 ]; then
firstWord=`echo $firstWord | tr "[a-z]" "[A-Z]"`
fi
otherWord=${word:1}
newWord=$firstWord$otherWord
words=$words$newWord

idx=`expr $idx + 1`
done
echo $words
}

rm -f $SYMBOL_DB_FILE
rm -f $HEAD_FILE
createTable

touch $HEAD_FILE
echo '#ifndef codeObfuscation_h
#define codeObfuscation_h' >> $HEAD_FILE
echo "//confuse string at `date`" >> $HEAD_FILE
cat "$STRING_SYMBOL_FILE" | while read -ra line; do
if [[ ! -z "$line" ]]; then
ramdom=`ramdomString`
echo $line $ramdom
insertValue $line $ramdom
echo "#define $line $MOTHOD_Macor$ramdom" >> $HEAD_FILE
fi
done
echo "#endif" >> $HEAD_FILE

sqlite3 $SYMBOL_DB_FILE .dump

