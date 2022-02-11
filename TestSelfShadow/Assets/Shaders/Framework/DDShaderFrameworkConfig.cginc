#ifndef DD_SHADER_FRAMEWORK_CONFIG_INCLUDED
#define DD_SHADER_FRAMEWORK_CONFIG_INCLUDED

#ifndef FUNC_VERTEX
#	define FUNC_VERTEX(x)
#endif

#ifndef FUNC_FINAL
#define FUNC_FINAL(x, worldPos) 
#endif

#ifndef UNITY_PASS_FORWARDADD
#	undef LIGHT_ATTEN_SEPERATE
#endif

#ifdef TEX1_UVST
#define TRANSTEX(i) (i.texcoord * TEX1_UVST.xy + TEX1_UVST.zw)
#else
#define TRANSTEX(i) (i.texcoord)
#endif

#define USE_TEX2
#if defined(TEX2_COORD2) || defined(LIGHTING_INPUT_NEED_UV2)
#define TRANSTEX2(i) (i.texcoord1)
#elif defined(TEX2_UVST)
#define TRANSTEX2(i) (i.texcoord * TEX2_UVST.xy + TEX2_UVST.zw)
#else
#define TRANSTEX2(i) (i.texcoord)
#undef USE_TEX2
#endif

#ifdef USE_TEX2
#	define SET_UV(o_uv, i) \
	o_uv.xy = TRANSTEX(i); \
	o_uv.zw = TRANSTEX2(i)
#else
#	define SET_UV(o_uv, i) o_uv.xy = TRANSTEX(i)
#endif

#ifdef USE_TEX2
#	define DD_UV_COORDS(idx) half4 uv : TEXCOORD##idx;
#else
#	define DD_UV_COORDS(idx) half2 uv : TEXCOORD##idx;
#endif

#if defined(TEX3_UVST)
#	define TRANSTEX3(i) (i.texcoord2 * TEX3_UVST.xy + TEX3_UVST.zw)
#	define USE_TEX3
#elif defined(TEX3_COORD3)
#	define TRANSTEX3(i) (i.texcoord2)
#	define USE_TEX3
#endif

#if defined(TEX4_UVST)
#	define TRANSTEX4(i) (i.texcoord3 * TEX4_UVST.xy + TEX4_UVST.zw)
#	define USE_TEX4
#elif defined(TEX4_COORD4)
#	define TRANSTEX4(i) (i.texcoord3)
#	define USE_TEX4
#endif
#if defined(USE_TEX3) && defined(USE_TEX4)
#	define SET_UV_EX(o, i)	\
	o.uvex.xy = TRANSTEX3(i); \
	o.uvex.zw = TRANSTEX4(i);
#	define DD_UV_COORDS_EX(idx) float4 uvex : TEXCOORD##idx;
#elif defined(USE_TEX3) || defined(USE_TEX4)
#ifdef USE_TEX3
#	define SET_UV_EX(o, i)	\
	o.uvex.xy = TRANSTEX3(i);
#else
#	define SET_UV_EX(o, i)	\
	o.uvex.xy = TRANSTEX4(i);
#endif
#	define DD_UV_COORDS_EX(idx) float2 uvex : TEXCOORD##idx;
#else
#	define SET_UV_EX(o, i)
#	define DD_UV_COORDS_EX(idx)
#endif

#ifdef NEED_VERTEX_COLOR
#	define DD_COLOR half4 color : COLOR;
#else
#	define DD_COLOR 
#endif

#if defined(INPUT_NEED_SCREEN_UV) || defined(LIGHTING_INPUT_NEED_SCREEN_UV)
#	define NEED_SCREEN_UV
#endif

#ifdef NEED_SCREEN_UV
#	define DD_SCREEN_UV_COORDS(idx) float4 screenUV : TEXCOORD##idx;
#else
#	define DD_SCREEN_UV_COORDS(idx)
#endif

#ifndef _VAR_CUTOFF
#define _VAR_CUTOFF _Cutoff
#endif

#ifndef USE_GI
#   define DD_V2F_INDIRECT_T    void
#   define DD_V2F_INDIRECT(idx) 
#endif

#define DD_GETXY(v) (v).xy
#define DD_GETZW(v) (v).zw

#ifdef USE_TEX2
#	define INIT_INPUT_UV(_INPUT_, i_uv) \
	_INPUT_.uv = DD_GETXY(i_uv);	\
	_INPUT_.uv2 = DD_GETZW(i_uv)
#else
#	define INIT_INPUT_UV(_INPUT_, i_uv) _INPUT_.uv = DD_GETXY(i_uv)
#endif

#if defined(USE_TEX3) && defined(USE_TEX4)
#	define INIT_INPUT_UV_EX(_INPUT_, i)	\
	_INPUT_.uv3 = DD_GETXY(i.uvex);	\
	_INPUT_.uv4 = DD_GETZW(i.uvex)
#elif defined(USE_TEX3)
#	define INIT_INPUT_UV_EX(_INPUT_, i)	\
	_INPUT_.uv3 = DD_GETXY(i.uvex)
#elif defined(USE_TEX4)
#	define INIT_INPUT_UV_EX(_INPUT_, i)	\
	_INPUT_.uv4 = DD_GETXY(i.uvex)
#else
#	define INIT_INPUT_UV_EX(_INPUT_, i) ;
#endif

#ifndef NEED_VERTEX_COLOR
#	define INIT_INPUT_COLOR(_INPUT_, i_color) ;
#else
#	define INIT_INPUT_COLOR(_INPUT_, i_color) _INPUT_.color = (i_color)
#endif

#if defined(INPUT_NEED_WORLD_POS) || defined(INPUT_NEED_WORLD_VERTEX_NORMAL) || defined(INPUT_NEED_WORLD_TANGENT)
#define _FRAMEWORK_NEED_TANGENT_TO_WORLD
#endif

#ifndef INPUT_NEED_WORLD_POS
#	define INIT_INPUT_WORLD_POS(_INPUT_, WORLD_POS) ;
#else
#	define INIT_INPUT_WORLD_POS(_INPUT_, WORLD_POS) _INPUT_.worldPos = (WORLD_POS)
#endif

#ifndef INPUT_NEED_WORLD_VERTEX_NORMAL
#	define INIT_INPUT_WORLD_VERTEX_NORMAL(_INPUT_, WORLD_VERTEX_NORMAL) ;
#else
#	define INIT_INPUT_WORLD_VERTEX_NORMAL(_INPUT_, WORLD_VERTEX_NORMAL) _INPUT_.worldVertexNormal = (WORLD_VERTEX_NORMAL)
#endif

#ifndef INPUT_NEED_WORLD_TANGENT
#	define INIT_INPUT_WORLD_TANGENT(_INPUT_, WORLD_TANGENT) ;
#else
#	define INIT_INPUT_WORLD_TANGENT(_INPUT_, WORLD_TANGENT) _INPUT_.worldTangent = (WORLD_TANGENT)
#endif

#ifndef INPUT_NEED_VIEWDIR_TANGENTSPACE
#	define INIT_INPUT_TANGENT_VIEW_DIR(_INPUT_, VIEW_DIR, WORLD_TANGENT, WORLD_BINORMAL, WORLD_VERTEX_NORMAL)	;
#else
#	define INIT_INPUT_TANGENT_VIEW_DIR(_INPUT_, VIEW_DIR, WORLD_TANGENT, WORLD_BINORMAL, WORLD_VERTEX_NORMAL)	_INPUT_.viewDirTS = mul(float3x3(WORLD_TANGENT, WORLD_BINORMAL, WORLD_VERTEX_NORMAL), VIEW_DIR)
#endif

#ifndef INPUT_NEED_SCREEN_UV
#	define INIT_INPUT_SCREEN_UV(_INPUT_, SCREEN_UV) ;
#else
#	define INIT_INPUT_SCREEN_UV(_INPUT_, SCREEN_UV)	\
	_INPUT_.grabScreenUV = SCREEN_UV.xy / SCREEN_UV.w;	\
	_INPUT_.screenUV = SCREEN_UV.xz / SCREEN_UV.w
#endif

#ifndef INPUT_NEED_DEPTH
#	define INIT_INPUT_DEPTH(_INPUT_, i_pos) ;
#else
#	define INIT_INPUT_DEPTH(_INPUT_, i_pos) _INPUT_.depth = i_pos.z
#endif

#define DD_INIT_INPUT(_INPUT_, _I_) \
	Input _INPUT_;	\
    INIT_INPUT_UV(_INPUT_, _I_.uv);	\
    INIT_INPUT_UV_EX(_INPUT_, _I_);	\
	INIT_INPUT_COLOR(_INPUT_, _I_.color);	\
	INIT_INPUT_WORLD_POS(_INPUT_, worldPos);	\
	INIT_INPUT_WORLD_VERTEX_NORMAL(_INPUT_, worldVertexNormal);	\
	INIT_INPUT_WORLD_TANGENT(_INPUT_, worldTangent);	\
	INIT_INPUT_TANGENT_VIEW_DIR(_INPUT_, viewDir, worldTangent, worldBinormal, worldVertexNormal);	\
	INIT_INPUT_SCREEN_UV(_INPUT_, _I_.screenUV);	\
	INIT_INPUT_DEPTH(_INPUT_, _I_.pos);	\

#define INIT_LIGHTING_INPUT_VIEWDIR(_INPUT_) _INPUT_.viewDir = viewDir
#define INIT_LIGHTING_INPUT_WORLDPOS(_INPUT_) _INPUT_.worldPos = worldPos
#define INIT_LIGHTING_INPUT_WORLDNORMAL(_INPUT_) _INPUT_.worldNormal = N
#define INIT_LIGHTING_INPUT_WORLDTANGENT(_INPUT_) _INPUT_.worldTangent = worldTangent

#ifndef LIGHTING_INPUT_NEED_UV2
#	define INIT_LIGHTING_INPUT_UV2(_INPUT_) ;
#else
#	define INIT_LIGHTING_INPUT_UV2(_INPUT_)	_INPUT_.uv2 = i.uv.zw
#endif

#ifndef LIGHTING_INPUT_NEED_SCREEN_UV
#	define INIT_LIGHTING_INPUT_SCREEN_UV(_INPUT_) ;
#else
#	define INIT_LIGHTING_INPUT_SCREEN_UV(_INPUT_)	\
	_INPUT_.grabScreenUV = i.screenUV.xy / i.screenUV.w;	\
	_INPUT_.screenUV = i.screenUV.xz / i.screenUV.w
#endif

#define DD_INIT_LIGHTING_INPUT(_INPUT_) \
	LightingInput _INPUT_;	\
	INIT_LIGHTING_INPUT_VIEWDIR(_INPUT_);	\
	INIT_LIGHTING_INPUT_WORLDPOS(_INPUT_);	\
	INIT_LIGHTING_INPUT_WORLDNORMAL(_INPUT_);	\
	INIT_LIGHTING_INPUT_WORLDTANGENT(_INPUT_);	\
	INIT_LIGHTING_INPUT_UV2(_INPUT_);	\
	INIT_LIGHTING_INPUT_SCREEN_UV(_INPUT_);	\

#endif