#define MAX_START_SPEED 		290.0
#define MAX_START_SPEED_SQR 	MAX_START_SPEED * MAX_START_SPEED

public void zones_OnPluginStart()
{
	/* Start off by looking for (and hooking) the zones! */
	zones_HookZones();
}

public void zones_OnMapStart()
{
	zones_HookZones(); // Re-hook the zones for the new map
}

void zones_HookZones()
{
	int entity = -1;
	char sName[128];
	while( ( entity = FindEntityByClassname( entity, "trigger_multiple" ) != -1 ) )
	{
		if ( !IsValidEntity( entity ) )
			continue;
		
		GetEntPropString( entity, Prop_Data, "m_iName", sName, sizeof( sName ) );
		
		if( StrContains( sName, "mod_zone" ) == 0 )
		{	
			// It's a zone!
			SDKHook( entity, SDKHook_StartTouch, Entity_StartTouch );
			SDKHook( entity, SDKHook_EndTouch, Entity_EndTouch );
		}
	}
}

void zone_GetZoneDetails( int entity, Zone& zoneType, int& index, int& track )
{
	char sName[128];
	char sDetails[6][64];
	
	zone_GetZoneName( entity, sName, sizeof( sName ) );
	ExplodeString( sName, "_", sDetails, sizeof( sDetails ), sizeof( sDetails[] ) );
	
	int num = 2;
	
	if( StrEqual( sDetails[num], "bonus" ) )
	{
		track = StringToInt( sDetails[num + 1] );
		num += 2;
	}
	else
	{
		track = 0;
	}
	
	if( StrEqual( sDetails[num], "start" ) )
	{
		index = -1;
		zoneType = Zone_Start;
	}
	else if( StrEqual( sDetails[num], "end" ) )
	{
		index = -1;
		zoneType = Zone_End;
	}
	else if( StrEqual( sDetails[num], "checkpoint" ) )
	{
		index = StringToInt( sDetails[num + 1] );
		zoneType = Zone_Checkpoint;
	}
}

public Action Entity_StartTouch( int entity, int client )
{
	if ( !IsValidClient( client ) )
		return;
		
	if( IsValidZone( entity ) )
		return;
		
	Zone zoneType;
	int zoneTrack, zoneIndex;
	zone_GetZoneDetails( entity, zoneType, zoneTrack, zoneIndex );
	
	switch( zoneType )
	{
		case Zone_Start:
		{
			// PLAYER ENTERED START
			timer_StopTimer( client );
			g_PlayerCurrentTrack[client] = zoneTrack;
		}
		case Zone_End:
		{
			// PLAYER ENTERED END
			if( g_bTimerStarted[client] && g_PlayerCurrentTrack[client] == zoneTrack )
			{
				timer_PlayerFinish( client, zoneTrack, g_PlayerCurrentStyle[client] );
			}
		}
		case Zone_Checkpoint:
		{
			if( g_bTimerStarted[client] && g_PlayerCurrentTrack[client] == zoneTrack )
			{
				timer_Checkpoint( client, zoneTrack, zoneIndex );
			}
		}
	}
	
	g_PlayerCurrentZone[client] = zoneType;
}

public Action Entity_EndTouch( int entity, int client )
{
	if( !IsValidZone( entity ) )
		return;
		
	Zone zoneType;
	int zoneTrack, zoneIndex;
	
	zone_GetZoneDetails( entity, zoneType, zoneIndex, zoneTrack );
	
	switch( zoneType )
	{
		case Zone_Start:
		{
			// PLAYER LEFT START ZONE
			if( GetClientSpeedSqr( client ) > MAX_START_SPEED_SQR )
			{
				PrintToChat( client, "Your start speed was too high, your timer has not been started" );
			}
			else if( !g_bTimerStarted[client] )
			{
				timer_StartTimer( client );
			}
		}
		case Zone_End:
		{
			// PLAYER LEFT END ZONE
		}
		case Zone_Checkpoint:
		{
			// PLAYER LEFT CHECKPOINT
		}
	}
	
	g_PlayerCurrentZone[client] = Zone_None;
}

stock void zone_GetZoneName( int entity, char[] buffer, int maxlen )
{
	GetEntPropString( entity, Prop_Data, "m_iName", buffer, maxlen );
}