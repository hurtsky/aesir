module ro.map.rsw;

import
		perfontain;


struct RswFile
{
	static immutable char[4] bom = `GRSW`;

	ubyte	vMajor, // TODO: VERSION CHECK
			vMinor;

	char[40]
				ini,
				gnd,
				gat,
				scr;

	/// water
	float wHeight;
	uint wType;

	float
			wAmpl,
			wSpeed,
			wPitch;

	uint wAnimSpeed;

	/// light
	uint
			longitude,
			latitude;

	Vector3
				diffuse,
				ambient;

	float intensity;

	/// ground
	uint
			gTop,
			gBottom,
			gLeft,
			gRight;

	@(`uint`) RswObject[] objects;
	@(`rest`) ubyte[] waste;
}

enum RswObjectType
{
	model = 1,
	light,
	sound,
	effect,
}

struct RswObject
{
	uint type;

	@(`ignoreif`, `type != 1`) RswModel model;
	@(`ignoreif`, `type != 2`) RswLight light;
	@(`ignoreif`, `type != 3`) RswSound sound;
	@(`ignoreif`, `type != 4`) RswEffect effect;
}

struct RswModel
{
	char[40] name;

	uint anim_type;
	float anim_speed;
	uint block_type;

	char[80]
				fileName,
				node;

	Vector3		pos,
				rot,
				scale;

	mixin readableToString;
}

struct RswLight
{
	char[80] name;

	Vector3
				pos,
				color;

	float range;
}

struct RswSound
{
	char[80]
				name,
				path;

	Vector3 pos;
	float vol;

	uint
			width,
			height;

	float range;
	@(`ignoreif`, `STRUCT.vMajor < 2`) float cycle; // ONLY RSW 2.+, FLOAT ???
}

struct RswEffect
{
	char[80] name;

	Vector3 pos;
	uint id;

	float delay;
	float[4] param;
}
