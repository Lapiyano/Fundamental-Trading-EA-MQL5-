﻿#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Blue

// include the file Trade.mqh
#include<Trade\Trade.mqh>

//create an instance of trade
CTrade trade;

input string   Time1="14:29:55";
input string   Time2="14:29:56";

input int      NumOfOrders=1; //NumOfOrders(BuyStop&SellStop)
input double   LotSize=0.01;  
input double   OrderPosition =10; //OrderPosition (In Pips)

input double   Layer=1.0;         //Barcode/Layer Entries (In Pips)
input double   TrailStop=10.0;    //Trailstop (In Pips)
input double   BreakEven=0;       //Breakeven (In Pips)


void OnTick()
  {
   
  
   
   int  NumOfOrders1=NumOfOrders;
   double LotSize1=LotSize;
   double OrderPosition1=OrderPosition;
   double   Layer1=Layer;
   
  eaName();
  UpperBoader();
  LowerBoarder();
  Creator();
  CreatorName();
  ExpiaryDate();
  CheckTime1(Time1);
  CheckTime1(Time2);
  string Operation1="TrailStop";
  string Operation2="BreakEven";
  int control=0;
  
  if(BreakEven==0){
   OperationType(Operation1);
   }
 
  else{
  
  OperationType(Operation2);
  }
  
   
   while(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)){
   
   
   AlgoTradingOff();
   
   }
   
   
   
  
  
    
    AlgoTradingOn();
  ///time control
   while(control==0 && TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)){ 
   
   datetime time = TimeLocal();
   string MinsSecs=TimeToString(time,TIME_SECONDS);
   if((StringSubstr(MinsSecs,0,8)==Time1) || (StringSubstr(MinsSecs,0,8)==Time2))
   {
   
   PlacePendignOrders(NumOfOrders1,LotSize1,OrderPosition1,Layer1);
  
   control++;
   } 
   
   }
   
   
   
   while(BreakEven==0 && TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)){
  
   int x=0;
   while(OrdersTotal()!=0){
   
   CheckSellTrailingStop();
   
   CheckBuyTrailingStop();
      x=1;
   }
   
    if(x!=0){
   
   DeleteOrders();
   }
   
  }
  
  
    while(BreakEven!=0 && TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)){
  
  int y=0;
  
   while(OrdersTotal()!=0){
   CheckSellBreakEven();
   
   CheckBuyBreakEven();
   y=1;
   }
   
   if(y!=0){
   
   DeleteOrders();
   }
   
  }
  
  
    while(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)){
   
   
   AlgoTradingOff();
   
   }
  
  
  }
  
  void DeleteOrders()
  {



for(int i=OrdersTotal()-1;i>=0;i--){


 ulong OrderTicket=OrderGetTicket(i);
 
trade.OrderDelete(OrderTicket);

}
   }
   
  
 void PlacePendignOrders(int NumOfOrders1,double LotSize1,double OrderPosition1,double layer1)
  {
  
  
  for(int i=0; i<NumOfOrders1;i++){
  
  double Ask=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
  double Bid=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);                                                                            
                                                                                  //stop loss  
  trade.BuyStop(LotSize1,(Ask+((Layer*(10)*(i)+OrderPosition1*(10))*_Point)),_Symbol,(Ask-(200-OrderPosition1*(10))*_Point),(Ask+(500+OrderPosition1*(10))*_Point),ORDER_TIME_GTC,0,NULL);
  
  
                                                                                  //stop loss               
  trade.SellStop(LotSize1,(Bid-((Layer*(10)*(i)+OrderPosition1*(10))*_Point)),_Symbol,(Ask+(200-OrderPosition1*(10))*_Point),(Ask-(500+OrderPosition1*(10))*_Point),ORDER_TIME_GTC,0,NULL);
  
  }
  
}

void CheckBuyTrailingStop(){
//****
double Bid=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);


  // set the desired stop loss to 150 points
  double SL=NormalizeDouble(Bid-(TrailStop*(10))*_Point,_Digits); 
   
  //check all open positions for the current symbol
  for(int i=PositionsTotal()-1; i>=0; i--) // count all currency pair positions
  {
   string symbol=PositionGetSymbol(i); // get positon symbol
   
   if (_Symbol==symbol) // if chart position equals position symbol	
   
   if(PositionGetInteger(POSITION_TYPE)==ORDER_TYPE_BUY)
   {
    // get ticket number  
    ulong PositionTicket=PositionGetInteger(POSITION_TICKET);
    
    //get the current stop loss 
    double CurrentStopLoss=PositionGetDouble(POSITION_SL);
    //*//
    double CurrentBid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
    //if current stoploss is below 15 points from ASK price
    if(CurrentStopLoss<SL)
    {
    //modify the stop loss by 10 Points
    trade.PositionModify(PositionTicket,(CurrentBid-(TrailStop*(10))*_Point),0);
    }
  }//end symbol if loop
 }//end for loop
}//end trailing stop function

void CheckSellTrailingStop(){

  double Ask=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
  // set the desired stop loss to 150 points
  double SL=NormalizeDouble(Ask+(TrailStop*(10))*_Point,_Digits); 
  
  //check all open positions for the current symbol
  for(int i=PositionsTotal()-1; i>=0; i--) // count all currency pair positions
  {
   string symbol=PositionGetSymbol(i); // get positon symbol
   
   if (_Symbol==symbol) // if chart position equals position symbol	
   
   if(PositionGetInteger(POSITION_TYPE)==ORDER_TYPE_SELL)
   {
    // get ticket number  
    ulong PositionTicket=PositionGetInteger(POSITION_TICKET);
    
    //get the current stop loss 
    double CurrentStopLoss=PositionGetDouble(POSITION_SL);
    //*//
    double CurrentAsk=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
    //if current stoploss is below 150 points from ASK price
    if(CurrentStopLoss>SL)
    {
    //modify the stop loss by 10 Points
    trade.PositionModify(PositionTicket,(CurrentAsk+(TrailStop*(10))*_Point),0);
    }
  }//end symbol if loop
 }//end for loop
}//end trailing stop function


void  CheckSellBreakEven(){

double Ask=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);

  //check all open positions for the current symbol
  for(int i=PositionsTotal()-1; i>=0; i--) // count all currency pair positions
  {
   string symbol=PositionGetSymbol(i); // get positon symbol
   
   if (_Symbol==symbol) // if chart position equals position symbol	
   
   if(PositionGetInteger(POSITION_TYPE)==ORDER_TYPE_SELL)
   {
    // get ticket number  
    ulong PositionTicket=PositionGetInteger(POSITION_TICKET);
    
    //get the current buy price
    double PositionSellPrice=PositionGetDouble(POSITION_PRICE_OPEN);
    //*//
    
    
    if(Ask<(PositionSellPrice-(BreakEven*(10))*_Point))
    {
    //modify to breakeven
    trade.PositionModify(PositionTicket,PositionSellPrice,0);
    }
  }//end symbol if loop
 }//end for loop


}
   
void CheckBuyBreakEven(){


   double Bid=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
   
  //check all open positions for the current symbol
  for(int i=PositionsTotal()-1; i>=0; i--) // count all currency pair positions
  {
   string symbol=PositionGetSymbol(i); // get positon symbol
   
   if (_Symbol==symbol) // if chart position equals position symbol	
   
   if(PositionGetInteger(POSITION_TYPE)==ORDER_TYPE_BUY)
   {
    // get ticket number  
    ulong PositionTicket=PositionGetInteger(POSITION_TICKET);
    
    //get the current buy price
    double PositionBuyPrice=PositionGetDouble(POSITION_PRICE_OPEN);
    //*//
    
    
    if(Bid>(PositionBuyPrice+(BreakEven*(10))*_Point))
    {
    //modify to breakeven
    trade.PositionModify(PositionTicket,PositionBuyPrice,0);
    }
  }//end symbol if loop
 }//end for loop
}


void eaName(){

  ObjectCreate(0,"eaName",OBJ_LABEL,0,0,0);
  ObjectSetString(0,"eaName",OBJPROP_FONT,"Arial");
  ObjectSetInteger(0,"eaName",OBJPROP_FONTSIZE,14);
  ObjectSetString(0,"eaName",OBJPROP_TEXT,0,"   ★彡[ 𝙈𝙚𝙜𝙖𝙏𝙧𝙖𝙞𝙡 ᴠ 1.0]彡★ ️");
  ObjectSetInteger(0,"eaName",OBJPROP_XDISTANCE,5);
  ObjectSetInteger(0,"eaName",OBJPROP_YDISTANCE,32);
  ObjectSetInteger(0,"eaName",OBJPROP_COLOR,clrDarkOrange);

}
   
void UpperBoader(){


  ObjectCreate(0,"Test1",OBJ_LABEL,0,0,0);
  ObjectSetString(0,"Test1",OBJPROP_FONT,"Arial");
  ObjectSetInteger(0,"Test1",OBJPROP_FONTSIZE,14);
  ObjectSetString(0,"Test1",OBJPROP_TEXT,0," ==================== ️");
  ObjectSetInteger(0,"Test1",OBJPROP_XDISTANCE,5);
  ObjectSetInteger(0,"Test1",OBJPROP_YDISTANCE,15);
  ObjectSetInteger(0,"Test1",OBJPROP_COLOR,clrOrange);
}

void LowerBoarder(){

   ObjectCreate(0,"Test2",OBJ_LABEL,0,0,0);
  ObjectSetString(0,"Test2",OBJPROP_FONT,"Arial");
  ObjectSetInteger(0,"Test2",OBJPROP_FONTSIZE,14);
  ObjectSetString(0,"Test2",OBJPROP_TEXT,0," ==================== ️");
  ObjectSetInteger(0,"Test2",OBJPROP_XDISTANCE,5);
  ObjectSetInteger(0,"Test2",OBJPROP_YDISTANCE,54);
  ObjectSetInteger(0,"Test2",OBJPROP_COLOR,clrOrange);

}
void Creator(){
  ObjectCreate(0,"Creator",OBJ_LABEL,0,0,0);
  ObjectSetString(0,"Creator",OBJPROP_FONT,"Arial");
  ObjectSetInteger(0,"Creator",OBJPROP_FONTSIZE,17);
  ObjectSetString(0,"Creator",OBJPROP_TEXT,0," 𝘊𝘳𝘦𝘢𝘵𝘦𝘥 𝘉𝘺: ️");
  ObjectSetInteger(0,"Creator",OBJPROP_XDISTANCE,5);
  ObjectSetInteger(0,"Creator",OBJPROP_YDISTANCE,525);
  ObjectSetInteger(0,"Creator",OBJPROP_COLOR,clrDarkGreen);
  }
  
  void CreatorName(){
  
  ObjectCreate(0,"CreatorName",OBJ_LABEL,0,0,0);
  ObjectSetString(0,"CreatorName",OBJPROP_FONT,"Arial");
  ObjectSetInteger(0,"CreatorName",OBJPROP_FONTSIZE,17);
  ObjectSetString(0,"CreatorName",OBJPROP_TEXT,0,"𝘓𝘢𝘱𝘪𝘺𝘢𝘯𝘰 𝘔𝘰𝘳𝘳𝘪𝘴 𝘔𝘢𝘯𝘨𝘢𝘯𝘩𝘦️");
  ObjectSetInteger(0,"CreatorName",OBJPROP_XDISTANCE,5);
  ObjectSetInteger(0,"CreatorName",OBJPROP_YDISTANCE,550);
  ObjectSetInteger(0,"CreatorName",OBJPROP_COLOR,clrDarkGreen);
  
  }
  
   void ExpiaryDate(){
  
  ObjectCreate(0,"ExpiaryDate",OBJ_LABEL,0,0,0);
  ObjectSetString(0,"ExpiaryDate",OBJPROP_FONT,"Arial");
  ObjectSetInteger(0,"ExpiaryDate",OBJPROP_FONTSIZE,12);
  ObjectSetString(0,"ExpiaryDate",OBJPROP_TEXT,0,"Expiary Date:   ️");
  ObjectSetInteger(0,"ExpiaryDate",OBJPROP_XDISTANCE,750);
  ObjectSetInteger(0,"ExpiaryDate",OBJPROP_YDISTANCE,550);
  ObjectSetInteger(0,"ExpiaryDate",OBJPROP_COLOR,clrBlue);
  
  }
  
   void OperationType(string Operation){
  
  ObjectCreate(0,"OperationType",OBJ_LABEL,0,0,0);
  ObjectSetString(0,"OperationType",OBJPROP_FONT,"Arial");
  ObjectSetInteger(0,"OperationType",OBJPROP_FONTSIZE,13);
  ObjectSetString(0,"OperationType",OBJPROP_TEXT,0," OperationType: "+Operation);
  ObjectSetInteger(0,"OperationType",OBJPROP_XDISTANCE,5);
  ObjectSetInteger(0,"OperationType",OBJPROP_YDISTANCE,75);
  ObjectSetInteger(0,"OperationType",OBJPROP_COLOR,clrBurlyWood);
  
  }

   void AlgoTradingOn(){
  
  ObjectCreate(0,"AlgoTrading",OBJ_LABEL,0,0,0);
  ObjectSetString(0,"AlgoTrading",OBJPROP_FONT,"Arial");
  ObjectSetInteger(0,"AlgoTrading",OBJPROP_FONTSIZE,17);
  ObjectSetString(0,"AlgoTrading",OBJPROP_TEXT,0,"꧁༒☬𝓜𝓐𝓨 𝓣𝓗𝓔 𝓢𝓟𝓘𝓚𝓔 𝓑𝓛𝓔𝓢𝓢 𝓨𝓞𝓤☬༒꧂️");
  ObjectSetInteger(0,"AlgoTrading",OBJPROP_XDISTANCE,5);
  ObjectSetInteger(0,"AlgoTrading",OBJPROP_YDISTANCE,104);
  ObjectSetInteger(0,"AlgoTrading",OBJPROP_COLOR,clrAqua);
  
  }
  
  void AlgoTradingOff(){
  
  ObjectCreate(0,"AlgoTrading",OBJ_LABEL,0,0,0);
  ObjectSetString(0,"AlgoTrading",OBJPROP_FONT,"Arial");
  ObjectSetInteger(0,"AlgoTrading",OBJPROP_FONTSIZE,17);
  ObjectSetString(0,"AlgoTrading",OBJPROP_TEXT,0," !! 𝐀𝐥𝐠𝐨 𝐓𝐫𝐚𝐝𝐢𝐧𝐠 𝐎𝐟𝐟 !! 🙁 ");
  ObjectSetInteger(0,"AlgoTrading",OBJPROP_XDISTANCE,5);
  ObjectSetInteger(0,"AlgoTrading",OBJPROP_YDISTANCE,104);
 ObjectSetInteger(0,"AlgoTrading",OBJPROP_COLOR,indicator_color2);
  
  
  
  }

  
 void CheckTime1(string time1){
 
 //1st character
 if(time1[0]=='0'  || time1[0]=='1'  || time1[0]=='2'){
 
 }
 
else{
  while(1){

  InvalidTime();
 }
 }
 //2nd charcter
 if(time1[1]=='0'  || time1[1]=='1'  || time1[1]=='2' || time1[1]=='3'  || time1[1]=='4' || time1[1]=='5' || time1[1]=='6' || time1[1]=='7' || time1[1]=='8' || time1[1]=='9'){
 
 }
 
else{
  while(1){

  
 InvalidTime();}
 
 }
 
 //3rd $ 6th  character
 if(time1[2]!=':'  && time1[5]!=':' ){
 

  while(1){
 InvalidTime();
         }
 
 }
 
 //4th character
  if(time1[3]=='0'  || time1[3]=='1'  || time1[3]=='2' || time1[3]=='3' || time1[3]=='4' || time1[3]=='5'){
 
 }
 
else{
  while(1){
 InvalidTime();
  
 }
 
 }
 
 //5th character
 
 if(time1[4]=='0'  || time1[4]=='1'  || time1[4]=='2' || time1[4]=='3' || time1[4]=='4' || time1[4]=='5' || time1[4]=='6' || time1[4]=='7' || time1[4]=='8' || time1[4]=='9'){
 
 }
 
else{
  while(1){
InvalidTime();
  
 }
 
 }
 //7th character
 if(time1[6]=='0'  || time1[6]=='1'  || time1[6]=='2' || time1[6]=='3' || time1[6]=='4' || time1[6]=='5'){
 
 }
 
else{
  while(1){
  InvalidTime();
  
 }
 
 }
 
 //8th character
 if(time1[7]=='0'  || time1[7]=='1'  || time1[7]=='2' || time1[7]=='3' || time1[7]=='4' || time1[7]=='5' || time1[7]=='6' || time1[7]=='7' || time1[7]=='8' || time1[7]=='9'){
 
 }
 
else{
  while(1){
InvalidTime();
  
 }
 
 }
 
 
 
   }//end
   
   
   
    
  void InvalidTime(){
  
  ObjectSetString(0,"AlgoTrading",OBJPROP_TEXT,0,"      ");
  
    ObjectCreate(0,"OperationType",OBJ_LABEL,0,0,0);
  ObjectSetString(0,"OperationType",OBJPROP_FONT,"Arial");
  ObjectSetInteger(0,"OperationType",OBJPROP_FONTSIZE,15);
  ObjectSetString(0,"OperationType",OBJPROP_TEXT,0," Invalid time ️");
  ObjectSetInteger(0,"OperationType",OBJPROP_XDISTANCE,5);
  ObjectSetInteger(0,"OperationType",OBJPROP_YDISTANCE,75);
   ObjectSetInteger(0,"AlgoTrading",OBJPROP_COLOR,clrRed);
   
   Sleep(100);
   
    ObjectCreate(0,"OperationType",OBJ_LABEL,0,0,0);
  ObjectSetString(0,"OperationType",OBJPROP_FONT,"Arial");
  ObjectSetInteger(0,"OperationType",OBJPROP_FONTSIZE,15);
  ObjectSetString(0,"OperationType",OBJPROP_TEXT,0,"--------");
  ObjectSetInteger(0,"OperationType",OBJPROP_XDISTANCE,5);
  ObjectSetInteger(0,"OperationType",OBJPROP_YDISTANCE,75);
     ObjectSetInteger(0,"AlgoTrading",OBJPROP_COLOR,clrRed);
   
   
    Sleep(100);
  }  
