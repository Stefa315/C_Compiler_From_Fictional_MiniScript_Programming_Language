/* program */

#include "mslib.h"

double limit, num, counter=3;
 int prime(double n) {
double i;
int result, isPrime;
if (n < 0){
result = prime (-n);
}; return result;

} ;

int main() {
limit = readNumber();
 num = 2;
 counter = 0;
 while (num <= limit)
{
if (prime (num)){
counter = counter + 1;
 writeNumber(num);
}; num = num + 1;
}
 writeString("\ngfsdgbs");
   writeString("45645456");
 writeNumber(counter);

}