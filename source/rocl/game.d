module rocl.game;

import
		std.file,
		std.json,
		std.array,
		std.getopt,
		std.algorithm,

		perfontain,
		perfontain.misc,
		perfontain.misc.report,

		ro.db,
		ro.str,
		ro.conv,
		rocl.loaders.asp,

		rocl,
		rocl.gui,
		rocl.status,
		rocl.entity,
		rocl.network,
		rocl.controls,
		rocl.resources,

		rocl.controller.npc,
		rocl.controller.item,
		rocl.controller.action,
		rocl.controller.effect;


@property ref RO() { return Game.instance; }

@property ROdb() { return RO._db; }
@property ROgui() { return RO._gmgr; }
@property ROent() { return RO._emgr; }
@property ROres() { return RO._rmgr; }
@property ROnet() { return RO._pmgr; }
@property ROnpc() { return RO._npc; }

final class Game
{
	__gshared instance = new Game;

	~this()
	{
		dtors;
	}

	void doInit()
	{
		auto js = readText(`aesir.json`).parseJSON;

		settings.serv = js[`server`].str;
		settings.grfs = js[`grfs`].array.map!(a => a.str).array;

		LANG = cast(ubyte)max(LANGS.countUntil(js[`lang`].str), 0);
	}

	void run(string[] args)
	{
		bool viewer;
		string login;

		getopt(args, `login`, &login, `viewer`, &viewer);

		if(!viewer && !login.length)
		{
			return;
		}

		if(initialize(login.length ? 15 : 45))
		{
			if(login.length)
			{
				auto r = login.findSplit(`:`);

				auto
						user = r[0],
						pass = r[2];

				ROgui.show;
				ROnet.login(user, pass);
			}
			else
			{
				mapViewer;
			}

			PE.work;
		}
	}

	RoSettings settings;

	Status status;
	ItemController items;
	ActionController action;
	EffectController effects;
package:
	void doExit()
	{
		PE.quit;
	}

private:
	void mapViewer()
	{
		debug
		{
			ROres.load(`prontera`);
		}
		else
		{
			ROres.load(`prontera`);
		}

		//PE.hotkeys.add(new Hotkey({ log(`lispsm %s`, PE.shadows.lispsm ^= true); }, SDL_SCANCODE_LCTRL, SDL_SCANCODE_A));
		debug
		{
			PE.hotkeys.add(new Hotkey({ PEstate.wireframe = !PEstate.wireframe; }, SDL_SCANCODE_F11));
			PE.hotkeys.add(new Hotkey({ PE.shadows.tex.toImage.saveToFile(`shadows.tga`, IM_TGA); }, SDL_SCANCODE_F10));
		}

		auto p = Vector3(0, 24.810, 0);
		PEscene.camera = new CameraFPS(p, p + Vector3(0.657, 0, -0.657));

		auto w = new WinSettings(true);
		PE.hotkeys.add(new Hotkey({ w.show(!w.visible); }, SDL_SCANCODE_F12));
	}

	bool initialize(uint fov)
	{
		auto t = TimeMeter(`main window creation`);

		void onAspect(float aspect)
		{
			PE.scene.proj = Matrix4.makePerspective(aspect, fov, 10, 500);
		}

		PE.onAspect.permanent(&onAspect);

		try
		{
			PE.create(`Æsir`);
		}
		catch(Exception e)
		{
			errorReport(e);
			showErrorMessage("Your graphics driver seems to be outdated.\nUpdate it and try again.\n\nError message: " ~ e.msg);
			return false;
		}

		PE.timers.add(&onWork, 0, 0);
		ctors;

		return true;
	}

	void onWork()
	{
		_pmgr.process;
		_emgr.process;
	}

	mixin createCtorsDtors!(_rmgr, _db, _gmgr, _emgr, _pmgr, _npc, action, status, items, effects);

	RoDb _db;

	GuiManager _gmgr;
	NpcController _npc;
	PacketManager _pmgr;
	EntityManager _emgr;
	ResourcesManager _rmgr;
}

struct RoSettings
{
	string serv;
	string[] grfs;
}
