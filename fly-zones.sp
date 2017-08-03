#define MAX_START_SPEED 		290.0
#define MAX_START_SPEED_SQR 	MAX_START_SPEED * MAX_START_SPEED

enum Zone
{
	Zone_None = -1,
	Zone_Start,
	Zone_End,
	Zone_Checkpoint
}

public void zones_OnPluginStart()
{
	/* Start off by looking for (and hooking) the zones! */
	zones_HookZones();
}

public void zones_OnMapStart()
{
	zones_HookZones(); /* Re-hook the zones for the new map */
}

void zones_HookZones()
{
	int entity = -1;
	char sName[128];
	while( ( entity = FindEntityByClassname( entity, "trigger_multiple" ) != -1 ) )
	{
		if ( !IsValidEntity( entity ) )
			continue;
		
		zone_GetZoneName( entity, sName, sizeof( sName ) );
		if( IsValidZone( entity ) )
		{	
			// It's a zone!
			SDKHook( entity, SDKHook_StartTouch, Entity_StartTouch );
			SDKHook( entity, SDKHook_EndTouch, Entity_EndTouch );
		}
	}
}

/*
 * Gives info of zone based on name
 * Gives zone type (start, end, checkpoint), checkpoint index (-1 if not applicable) and track number (0 for main)
 * Takes entity index and reference to variables for storing the details
 */
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
	if( !IsValidClient( client ) || !IsValidZone( entity ) )
		return;
		
	Zone zoneType;
	int zoneTrack, zoneIndex;
	zone_GetZoneDetails( entity, zoneType, zoneTrack, zoneIndex );
	
	switch( zoneType )
	{
		case Zone_Start:
		{
			/* PLAYER ENTERED START */
			timer_StopTimer( client );
			g_PlayerCurrentTrack[client] = zoneTrack;
		}
		case Zone_End:
		{
			/* PLAYER ENTERED END */
			if( g_bTimerStarted[client] && g_PlayerCurrentTrack[client] == zoneTrack )
			{
				timer_PlayerFinish( client, zoneTrack, g_PlayerCurrentStyle[client] );
			}
		}
		case Zone_Checkpoint:
		{
			/* PLAYER ENTERED CHECKPOINT */
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
	if( !IsValidClient( client ) || !IsValidZone( entity ) )
		return;
		
	Zone zoneType;
	int zoneTrack, zoneIndex;
	
	zone_GetZoneDetails( entity, zoneType, zoneIndex, zoneTrack );
	
	switch( zoneType )
	{
		case Zone_Start:
		{
			/* PLAYER LEFT START ZONE */
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
			/* PLAYER LEFT END ZONE */
		}
		case Zone_Checkpoint:
		{
			/* PLAYER LEFT CHECKPOINT */
		}
	}
	
	g_PlayerCurrentZone[client] = Zone_None;
}

stock void zone_GetZoneName( int entity, char[] buffer, int maxlen )
{
	GetEntPropString( entity, Prop_Data, "m_iName", buffer, maxlen );
}

/* Simply checks whether the name of the entity starts with "mod_zone_" */
stock bool IsValidZone( int entity )
{
	char name[64];
	zone_GetZoneName( entity, name, sizeof( name ) );
	
	return ( StrContains( name, "mod_zone_" ) == 0 );
}

stock float GetClientSpeedSqr( int client )
{
	float vel[2];
	vel[0] = GetEntPropFloat( client, Prop_Data, "m_vecVelocity[0]" );
	vel[1] = GetEntPropFloat( client, Prop_Data, "m_vecVelocity[1]" );
	
	return ( ( vel[0]*vel[0] ) + ( vel[1]*vel[1] ) );
}

stock float GetClientSpeed( int client )
{
	return SquareRoot( GetClientSpeedSqr( client ) );
}

stock void SetClientSpeed( int client, float speed )
{
	if( IsValidClient( client ) && IsPlayerAlive( client ) )
	{
		float player_vel[3];
		GetEntPropVector( client, Prop_Data, "m_vecVelocity", player_vel );

		float scale = speed / GetClientSpeed( client );

		if( scale < 1.0 )
		{
			ScaleVector( player_vel, scale );
			TeleportEntity( client, NULL_VECTOR, NULL_VECTOR, player_vel );
		}
	}
}