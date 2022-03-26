
var limit, num, counter=3: number;
//const x="string" : string;

function prime(n: number): boolean {
   var i: number; 
   var result, isPrime: boolean;
     
   if (n < 0) {
      result = prime(-n);
   }
   else if (n < 2) {
      result = false;
   }
   else if (n == 2) {
      result = true;
   }
   else if (n % 2 == 0) {
      result = false;
   }
   else { 
      i = 3;
      isPrime = true;
      while (isPrime and (i < n / 2) ) { 
         isPrime = n % i != 0;
         i = i + 2;
      };
      result = isPrime;
   };
  
   return result;
};
function start(): void {

   limit = readNumber();
   num = 2;
   counter = 0;

   while (num <= limit) { 
      if (prime(num)) { 
         counter = counter + 1;
      writeNumber(num);
   
      
      };
      num = num + 1;
   };
   writeString("\ngfsdgbs");
   writeString("45645456");
   writeNumber(counter);   
}