struct DatexTime
{
  int year;
  int month;
  int day;
  int hour;
  int minute;
  int second;

  DatexTime()
  {
  }

  DatexTime(byte y, byte m, byte d, byte h, byte mm, byte s)
  {
    year = ((int)y + 2000);
    month = m;
    day = d;
    hour = h;
    minute = mm;
    second = s;
  }

  String getStringDateForFile()
  {
    String separator = String('-');

    return year + separator + month + separator + day + ".txt";
  }

  String toString()
  {
    String dateSeparator = String('-');
    String timeSeparator = String(':');

    return year + dateSeparator + month + dateSeparator + day + String(' ') + hour + timeSeparator + minute + timeSeparator + second;
  }
};