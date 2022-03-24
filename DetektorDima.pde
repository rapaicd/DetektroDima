char pozar[] = "Pozar!";
int poruka;
float MQ3;
float temperatura;
int adresa = 1024;
int adresa2 = 1024;
char *Upis;
char Ispis;
char rec[30];

void setup ()
{

  USB.begin ();
  Utils.setLED (LED1, LED_ON);  //Paljenje zelenog LED-a
  RTC.ON ();      //Paljenje RTC senzora
  RTC.setTime ("21:06:09:04:13:35:00"); //Postavljanje vremena
  USB.println (F ("Zagrevanje MQ3 senzora!"));
  delay (20000);    //Čekanje 20 sekundi da se MQ3 senzor zagreje
  poruka = GPRS_Pro.ON ();
  if ((poruka == 1) || (poruka == -3))  //Provera da li je GSM instaliran na mikrokontroleru
    {
      USB.println (F ("GPRS_Pro modul je spreman..."));
      poruka = GPRS_Pro.check (180);
      if (poruka == 1)    //Provera da li je kartica validna I pravilno stavljena
  {
    USB.println (F ("GPRS_Pro modul je konektovan na mrezu..."));
  }
      else
  {
    USB.println (F ("Ne moze da se poveze na mrezu"));
  }
    }
  else
    {
      USB.println (F ("GPRS modem nije instaliran"));
    }
  poruka = 0;
}

void loop ()
{

  MQ3 = analogRead (ANALOG4); //Dodeljivanje vrednosti promenljivoj MQ3 sa ANALOG4 pina
  USB.print (F ("Vrednost sa senzora MQ3: "));
  USB.println (MQ3, DEC);
  while (MQ3 > 400)
    {       //Ulazak u petlju ukoliko je vrednost MQ3 senzora veca od 400
      Utils.setLED (LED1, LED_OFF);
      Utils.setLED (LED0, LED_ON);  //Blinkanje crvene diode na svakih pola sekunde i gašenje zelene
      delay (500);
      Utils.setLED (LED0, LED_OFF);
      delay (500);
      USB.print (F ("Detektovan dim, "));
      temperatura = RTC.getTemperature ();  //Dodeljivanje temperature sa RTC senzora promenljivoj
      if (temperatura > 100)
  {     //Ulazak u petlju ukoliko je temperatura sa senzora veća od 100 stepeni
    Utils.setLED (LED0, LED_ON);  //Trajno paljenje crvene diode sve dok je temperatura veca od 100
                     // stepeni
    USB.println (F ("temperatura je iznad sto stepeni.\n Oglasavam alarm u hotelu za 5 sekundi!"));
    RTC.setAlarm1 ("00,00,00,05", RTC_OFFSET, RTC_ALM1_MODE4);  //Postavljanje alarma da se 
                               // oglasi za 5 sekundi
    for (int i = 5; i > 0; i--)
      {
        USB.print (i);
        USB.println (F ("..."));
        delay (1000);
      }     //Odbroja 5 sekundi
    RTC.clearAlarmFlag ();  //Brisanje alarm flega       
    USB.println (F (“Alarm aktiviran!”));
    Upis = RTC.getTime ();
    for (int i = 0; /*Upis[i] != '\0' */ i < 30; i++)
      {     //Upis vremena paljenja alarma u EEPROM
        Utils.writeEEPROM (adresa, Upis[i]);
        adresa++;
        if (adresa == 4096)
    {
      adresa = 1024;
    }
      }

    for (int i = 0; i < 30; i++)
      {     //Ispis vremena iz EEPROM-a u string rec
        Ispis = Utils.readEEPROM (adresa2);
        rec[i] = Ispis;
        adresa2++;
        if (adresa2 == 4096)
    {
      adresa2 = 1024;
    }
      }
    USB.print ("Vreme paljenja alarma je: ");
    USB.println (rec);  //Ispis vremena paljenja alarma na UART
    if (GPRS_Pro.sendSMS (pozar, "+381695822667") == 1)
      {     //Slanje poruke na odredjeni broj sa tekstom
        //poruke “Pozar!”
        USB.println (F ("Poruka o pozaru poslata!"));
        delay (20000);
      }
  }
      else
  {
    USB.println (F ("ali nema pozara. Moguc dim cigarete!"));
  }

      MQ3 = analogRead (ANALOG4);
      Utils.setLED (LED0, LED_OFF);
    }
  Utils.setLED (LED1, LED_ON);
  delay (1000);
}

