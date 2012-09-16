/*

This code is MIT licensed, see http://www.opensource.org/licenses/mit-license.php
(C) 2010 - 2012 Simple Loop 

*/

#include "gideros.h"

#import <MediaPlayer/MediaPlayer.h>

static const MPMusicPlayerController* musicPlayer;

static int stackdump(lua_State* l)
{
    // Thanks, Caroline Begbie
    NSLog(@"stackdump");
    
    int top = lua_gettop(l);
    //Returns index of the top most element. And hence, it is the number of Stack elements
    
    for (int i = 1; i <= top; i++)
    {
        printf("  ");
        int t = lua_type(l, i);
        switch (t) {
            case LUA_TSTRING:  //strings
                printf("string: '%s'\n", lua_tostring(l, i));
                break;
            case LUA_TBOOLEAN:  //booleans
                printf("boolean %s\n",lua_toboolean(l, i) ? "true" : "false");
                break;
            case LUA_TNUMBER:  //numbers
                printf("number: %g\n", lua_tonumber(l, i));
                break;
            default:  //other values
                printf("%s\n", lua_typename(l, t));
                break;
        }
    }
    printf("\n");
    return 0;
}

static int playPause(lua_State *L)
{
    if ([musicPlayer playbackState] == MPMusicPlaybackStatePlaying) {
        [musicPlayer pause];
    } else {
        [musicPlayer play];
    }
    return 0;
}

static int previousSong(lua_State *L)
{
    [musicPlayer skipToPreviousItem];
    return 0;
}

static int nextSong(lua_State *L)
{
    [musicPlayer skipToNextItem];
    return 0;
}

static int seekForwards(lua_State *L)
{
    [musicPlayer beginSeekingForward];
    return 0;
}

static int seekBackwards(lua_State *L)
{
    [musicPlayer beginSeekingBackward];
    return 0;
}

static int stopSeeking(lua_State *L)
{
    [musicPlayer endSeeking];
    return 0;
}

static int stopSong(lua_State *L)
{
    [musicPlayer stop];
    return 0;
}

static int playSong(lua_State *L)
{
    [musicPlayer play];
    return 0;
}

static int pauseSong(lua_State *L)
{
    [musicPlayer pause];
    return 0;
}

static int skipToBeginning(lua_State *L)
{
    [musicPlayer skipToBeginning];
    return 0;
}

static int getPlaylists(lua_State *L)
{
    MPMediaQuery *playlistsQuery = [MPMediaQuery playlistsQuery];
    NSArray* playlists = [playlistsQuery collections];
    
    lua_newtable(L);
    
    int i=1;
    NSLog(@"On: %d", [playlists count]);
    
    for (MPMediaPlaylist *playlist in playlists) {
        //STACK {   table   }
        lua_pushnumber(L,i);
        //STACK {  table   key     }
        lua_pushstring(L, [[playlist valueForProperty: MPMediaPlaylistPropertyName]UTF8String]);
        //STACK {  table   key     value   }
        lua_settable(L,1);
        i=i+1;
    }
    
    return 1;
}

static int getSongs(lua_State *L)
{
    MPMediaQuery *playlistsQuery = [MPMediaQuery playlistsQuery];
    NSArray* playlists = [playlistsQuery collections];
    
    int playNum = 0;//lua_tonumber(L, 0);
    
    MPMediaPlaylist *playlist = playlists[playNum];
    NSArray *songs = [playlist items];
    
    lua_newtable(L);
    
    int i=1;
    
    for (MPMediaItem *song in songs) {
        //STACK {   table   }
        lua_pushnumber(L,i);
        //STACK {  table   key     }
        lua_pushstring(L, [[song valueForProperty: MPMediaItemPropertyTitle] UTF8String]);
        //STACK {  table   key     value   }
        lua_settable(L,1);
        i=i+1;
    }
    
    return 1;
}

static int getPlayState(lua_State *L)
{
    NSString *playState;
    
    if ([musicPlayer playbackState] == MPMusicPlaybackStatePlaying) {
        playState = @"playing";
    } else {
        playState = @"paused";
    }

    //lua_pushstring(L, playState);
    
    return 1;
}

static int loader(lua_State *L)
{
    const luaL_Reg functionlist[] = {
        {"playPause",playPause},
        {"playSong",playSong},
        {"pauseSong",pauseSong},
        {"stopSong",stopSong},
        {"previousSong",previousSong},
        {"nextSong",nextSong},
        {"seekForwards",seekForwards},
        {"seekBackwards",seekBackwards},
        {"stopSeeking",stopSeeking},
        {"skipToBeginning",skipToBeginning},
        {"getPlaylists",getPlaylists},
        {"getSongs",getSongs},
        {"getPlayState",getPlayState},
        {NULL, NULL},
    };
    luaL_register(L, "musicKit", functionlist);
    
    return 0;
}

static void g_initializePlugin(lua_State* L)
{
    lua_getglobal(L, "package");
    //STACK :   { _G.package}
    lua_getfield(L, -1, "preload");
    //STACK :   {_G.package.preload     _G.package}
    lua_pushcfunction(L, loader);
    //STACK :   {loader     _G.package.preload     _G.package}
    lua_setfield(L, -2, "musicKit");
    //STACK :   { _G.package.preload     _G.package}
    lua_pop(L, 2);
    
    if (musicPlayer == nil) {
        musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    }
    
    glog_setLevel(GLOG_SUPPRESS);
}

static void g_deinitializePlugin(lua_State *L)
{
}

REGISTER_PLUGIN("musicKit", "1.0")