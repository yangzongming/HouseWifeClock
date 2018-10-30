enum {
	kState_NewClock = 0,
	kState_OldClock,
};
enum {
	Clock_PushType_NewClock  = kState_NewClock,
	Clock_PushType_OldClock = kState_OldClock,
};


#define KScreenHeight [[UIScreen mainScreen] bounds].size.height