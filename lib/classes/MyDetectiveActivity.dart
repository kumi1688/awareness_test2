class MyDetectiveActivity {
  String _type;
  int _confidence;

   static final int IN_VEHICLE = 0;
   static final int ON_BICYCLE = 1;
   static final int ON_FOOT = 2;
   static final int STILL = 3;
   static final int UNKNOWN = 4;
   static final int TILTING = 5;
   static final int WALKING = 7;
   static final int RUNNING = 8;



//  public MyDetectiveActivity(int type, int confidence){
//    super();
//    this._type = getType(type);
//    this._confidence = confidence;
//  }
//
//  public String getType(int type){
//    switch(type){
//      case IN_VEHICLE:    return "IN_VEHICLE";
//      case ON_BICYCLE:    return "ON_BICYCLE";
//      case ON_FOOT:       return "ON_FOOT";
//      case STILL:         return "STILL";
//      case TILTING:       return "TILTING";
//      case WALKING:       return "WALKING";
//      case RUNNING:       return "RUNNING";
//      default:            return "UNKNOWN";
//    }
//  }
//
//  public int getConfidence(){
//    return this._confidence;
//  }
}
