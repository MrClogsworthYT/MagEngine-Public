package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import openfl.Assets;
import haxe.Json;
import haxe.format.JsonParser;
#if sys
import sys.io.File;
import sys.FileSystem;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
#end

using StringTools;

class StoryMenuState extends MusicBeatState
{
	var scoreText:FlxText;

	var curDifficulty:Int = 1;


	var weeksArray:Array<String> = [];


	var swagbf:FlxSprite;

	
	var weekthingy:Array<String> = CoolUtil.coolTextFile(Paths.txt('weeks/weekList'));


	var weekNames:Array<String> = CoolUtil.coolTextFile(Paths.txt('data/weekNames'));

	var txtWeekTitle:FlxText;

	var curWeek:Int = 0;
	
	var getPreloadPath:Array<String> = [Paths.getPreloadPath('')];

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var weekbg:FlxSprite;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var _swagweek:SwagWeek;
	var swagger:Array<SwagWeek>;
	
	

	override function create()
	{
		function getJSON(path:String):SwagWeek {
			var rawJson:String = null;
			//we use file.getcontent so it reads from the mods folder
			if(FileSystem.exists(path)) {
				rawJson = File.getContent(path);
			}
			if(rawJson != null && rawJson.length > 0) {
				return cast Json.parse(rawJson);
			}
			return null;
		}


		function parseJSONshit(rawJson:String):SwagWeek
			{
				var swagShit:SwagWeek = cast Json.parse(rawJson);
				return swagShit;
			}

        //LMAO STOLEN FROM SONG
		function loadFromWEEKJson(jsonInput:String):SwagWeek
			{
				var rawJson = null;
				var moddyFile:String = Paths.modsong('weeks/' + jsonInput);
				if(FileSystem.exists(moddyFile)) {
					rawJson = File.getContent(moddyFile).trim();
				}
		
				if(rawJson == null) {
					//why the fuck did i do this lmao
					#if sys
					rawJson = File.getContent(Paths.cooljson('weeks/' + jsonInput)).trim();
					#else
					rawJson = Assets.getText(Paths.cooljson('weeks/' + jsonInput)).trim();
					#end
				}
		
				while (!rawJson.endsWith("}"))
				{
					rawJson = rawJson.substr(0, rawJson.length - 1);
					// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
				}

				var weekJson:SwagWeek = parseJSONshit(rawJson);
				return weekJson;
			}

			weeksArray = [];
			for (i in 0...weekthingy.length) {
				weeksArray.push(weekthingy[i]);
				var filethingy:String = 'weeks/' + weeksArray[i] + '.json';
				var swagshit:SwagWeek = getJSON(filethingy);
			}
	

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut; 

		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.bold = true;
		txtWeekTitle.alpha = 0.7;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		var yellowBG:FlxSprite = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, 0xFFF9CF51);

		
		var bg:FlxSprite = new FlxSprite(FlxG.width * 0.07, yellowBG.y + 420).loadGraphic(Paths.image('storybg', 'MagEngine'));
        bg.antialiasing = true;
		bg.screenCenter(X);
		bg.screenCenter(Y);
		add(bg);

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);


		var itsanillusionn:FlxSprite = new FlxSprite().loadGraphic(Paths.image('illusion', 'MagEngine'));
		itsanillusionn.antialiasing = true;
		add(itsanillusionn);

		
		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 470, 0xFFF9CF51);
		blackBarThingie.alpha = 0.5;
		add(blackBarThingie);
		
		swagbf = new FlxSprite(420, 30);
		swagbf.antialiasing = true;
		swagbf.frames = Paths.getSparrowAtlas('BOYFRIEND'); 
		swagbf.animation.addByPrefix('idle', 'BF idle dance', 24, true);
		swagbf.animation.addByPrefix('hey', 'BF HEY', 24, false);
		swagbf.animation.play('idle');
		add(swagbf);

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		trace("Line 70");
		
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		for (i in 0...weekthingy.length)
		{
			var weekThing:MenuItem = new MenuItem(0, yellowBG.y + yellowBG.height + 10, i);
			weekThing.y += ((weekThing.height + 20) * i);
			weekThing.targetY = i;
			weekThing.screenCenter(X);
			grpWeekText.add(weekThing);

			weekThing.antialiasing = true;
			// weekThing.updateHitbox();


		}

		trace("Line 96");

		
		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		trace("Line 124");

		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 10, grpWeekText.members[0].y + 10);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		difficultySelectors.add(leftArrow);

		sprDifficulty = new FlxSprite(leftArrow.x + 130, leftArrow.y);
		sprDifficulty.frames = ui_tex;
		sprDifficulty.animation.addByPrefix('easy', 'EASY');
		sprDifficulty.animation.addByPrefix('normal', 'NORMAL');
		sprDifficulty.animation.addByPrefix('hard', 'HARD');
		sprDifficulty.animation.play('easy');
		changeDifficulty();

		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(sprDifficulty.x + sprDifficulty.width + 50, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		difficultySelectors.add(rightArrow);

		trace("Line 150");

		var tracksarelookinggood:FlxSprite = new FlxSprite(FlxG.width * 0.07, yellowBG.y + 425).loadGraphic(Paths.image('ThefunneMenuTracks'));
		tracksarelookinggood.antialiasing = true;
		add(tracksarelookinggood);

	

		txtTracklist = new FlxText(FlxG.width * 0.05, yellowBG.x + yellowBG.height + 200, 0, "", 32);
		txtTracklist = new FlxText(FlxG.width * 0.05, tracksarelookinggood.y + 40, 0, "", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.setFormat(Paths.font("funkin.otf"), 42);
		txtTracklist.color = 0xFFe55777;
		add(txtTracklist);
		// add(rankText);
		add(scoreText);
		add(txtWeekTitle);

		updateText();

		trace("Line 165");

		super.create();
	}

	override function update(elapsed:Float)
	{
		// scoreText.setFormat('VCR OSD Mono', 32)

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5));

		scoreText.text = "WEEK SCORE:" + lerpScore;

		txtWeekTitle.text = weekNames[curWeek].toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		// FlxG.watch.addQuick('font', scoreText.font);


		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
		});

		if (!movedBack)
		{
			if (!selectedWeek)
			{
				if (controls.UP_P)
				{
					changeWeek(-1);
				}

				if (controls.DOWN_P)
				{
					changeWeek(1);
				}

				if (controls.RIGHT)
					rightArrow.animation.play('press')
				else
					rightArrow.animation.play('idle');

				if (controls.LEFT)
					leftArrow.animation.play('press');
				else
					leftArrow.animation.play('idle');

				if (controls.RIGHT_P)
					changeDifficulty(1);
				if (controls.LEFT_P)
					changeDifficulty(-1);
			}

			if (controls.ACCEPT)
			{
				swagbf.animation.play('hey');
				selectWeek();
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			FlxG.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('titleShoot'));

				grpWeekText.members[curWeek].startFlashing();
				stopspamming = true;
			}

			PlayState.storyPlaylist = loadFromWEEKJson(weeksArray[curWeek]).songs;
			PlayState.isStoryMode = true;
			selectedWeek = true;

			var diffic = "";

			switch (curDifficulty)
			{
				case 0:
					diffic = '-easy';
				case 2:
					diffic = '-hard';
			}
			PlayState.storyDifficulty = curDifficulty;

			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.storyWeek = curWeek;
			PlayState.campaignScore = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState(), true);
			});
		
	}
	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		sprDifficulty.offset.x = 0;

		switch (curDifficulty)
		{
			case 0:
				sprDifficulty.animation.play('easy');
				sprDifficulty.offset.x = 20;
			case 1:
				sprDifficulty.animation.play('normal');
				sprDifficulty.offset.x = 70;
			case 2:
				sprDifficulty.animation.play('hard');
				sprDifficulty.offset.x = 20;
		}

		sprDifficulty.alpha = 0;

		// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
		sprDifficulty.y = leftArrow.y - 15;
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end

		FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07);
	}

	function loadFromWEEKJson(jsonInput:String):SwagWeek
		{
			var rawJson = null;
			var moddyFile:String = Paths.modsong('weeks/' + jsonInput);
			if(FileSystem.exists(moddyFile)) {
				rawJson = File.getContent(moddyFile).trim();
			}
	
			if(rawJson == null) {
				//why the fuck did i do this lmao
				#if sys
				rawJson = File.getContent(Paths.cooljson('weeks/' + jsonInput)).trim();
				#else
				rawJson = Assets.getText(Paths.cooljson('weeks/' + jsonInput)).trim();
				#end
			}
	
			while (!rawJson.endsWith("}"))
			{
				rawJson = rawJson.substr(0, rawJson.length - 1);
				// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
			}

			var weekJson:SwagWeek = parseJSONshit(rawJson);
			return weekJson;
		}
			function parseJSONshit(rawJson:String):SwagWeek
			{
				var swagShit:SwagWeek = cast Json.parse(rawJson);
				return swagShit;
			}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= weeksArray.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = weeksArray.length - 1;

		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0))
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		FlxG.sound.play(Paths.sound('scrollMenu'));


		updateText();
	}

	function updateText()
	{
		txtTracklist.text = '';
		
		var stringThing:Array<String> = loadFromWEEKJson(weeksArray[curWeek]).songs;

		for (i in stringThing)
		{
			txtTracklist.text += "\n" + i;
		}
	
		txtTracklist.text += "\n";
		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end
	}
}
typedef SwagWeek =
{
	var songs:Array<String>;
}
class Week
{
	public var songs:Array<String>;

	public function new(swagWeek:SwagWeek) {
		songs = swagWeek.songs;
	}
}
