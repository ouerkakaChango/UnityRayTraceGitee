#ifndef WOODNOISE_HLSL
#define WOODNOISE_HLSL

//https://www.shadertoy.com/view/ldscDM

// Noise generator from https://otaviogood.github.io/noisegen/
// Params: 3D, Seed 1, Waves 128, Octaves 7, Smooth 1
float WoodNoiseGen128(float3 p) {
    // This is a bit faster if we use 2 accumulators instead of 1.
    // Timed on Linux/Chrome/TitanX Pascal
    float wave0 = 0.0;
    float wave1 = 0.0;
    wave0 += sin(dot(p, float3(-1.316, 0.918, 1.398))) * 0.0783275458;
    wave1 += sin(dot(p, float3(0.295, -0.176, 2.167))) * 0.0739931495;
    wave0 += sin(dot(p, float3(-0.926, 1.445, 1.429))) * 0.0716716966;
    wave1 += sin(dot(p, float3(-1.878, -0.174, 1.258))) * 0.0697839187;
    wave0 += sin(dot(p, float3(-1.995, 0.661, -0.908))) * 0.0685409863;
    wave1 += sin(dot(p, float3(-1.770, 1.350, -0.905))) * 0.0630152419;
    wave0 += sin(dot(p, float3(2.116, -0.021, 1.161))) * 0.0625361712;
    wave1 += sin(dot(p, float3(0.405, -1.712, -1.855))) * 0.0567751048;
    wave0 += sin(dot(p, float3(1.346, 0.945, 1.999))) * 0.0556465603;
    wave1 += sin(dot(p, float3(-0.397, -0.573, 2.495))) * 0.0555747667;
    wave0 += sin(dot(p, float3(0.103, -2.457, -1.144))) * 0.0516322279;
    wave1 += sin(dot(p, float3(-0.483, -1.323, 2.330))) * 0.0513093320;
    wave0 += sin(dot(p, float3(-1.715, -1.810, -1.164))) * 0.0504567036;
    wave1 += sin(dot(p, float3(2.529, 0.479, 1.011))) * 0.0500811899;
    wave0 += sin(dot(p, float3(-1.643, -1.814, -1.437))) * 0.0480875812;
    wave1 += sin(dot(p, float3(1.495, -1.905, -1.648))) * 0.0458268348;
    wave0 += sin(dot(p, float3(-1.874, 1.559, 1.762))) * 0.0440084357;
    wave1 += sin(dot(p, float3(1.068, -2.090, 2.081))) * 0.0413624154;
    wave0 += sin(dot(p, float3(-0.647, -2.197, -2.237))) * 0.0401592830;
    wave1 += sin(dot(p, float3(-2.146, -2.171, -1.135))) * 0.0391682940;
    wave0 += sin(dot(p, float3(2.538, -1.854, -1.604))) * 0.0349588163;
    wave1 += sin(dot(p, float3(1.687, 2.191, -2.270))) * 0.0342888847;
    wave0 += sin(dot(p, float3(0.205, 2.617, -2.481))) * 0.0338465332;
    wave1 += sin(dot(p, float3(3.297, -0.440, -2.317))) * 0.0289423448;
    wave0 += sin(dot(p, float3(1.068, -1.944, 3.432))) * 0.0286404261;
    wave1 += sin(dot(p, float3(-3.681, 1.068, 1.789))) * 0.0273625684;
    wave0 += sin(dot(p, float3(3.116, 2.631, -1.658))) * 0.0259772492;
    wave1 += sin(dot(p, float3(-1.992, -2.902, -2.954))) * 0.0245830241;
    wave0 += sin(dot(p, float3(-2.409, -2.374, 3.116))) * 0.0245592756;
    wave1 += sin(dot(p, float3(0.790, 1.768, 4.196))) * 0.0244078334;
    wave0 += sin(dot(p, float3(-3.289, 1.007, 3.148))) * 0.0241328015;
    wave1 += sin(dot(p, float3(3.421, -2.663, 3.262))) * 0.0199736126;
    wave0 += sin(dot(p, float3(3.062, 2.621, 3.649))) * 0.0199230290;
    wave1 += sin(dot(p, float3(4.422, -2.206, 2.621))) * 0.0192399437;
    wave0 += sin(dot(p, float3(2.714, 3.022, 4.200))) * 0.0182510631;
    wave1 += sin(dot(p, float3(-0.451, 4.143, -4.142))) * 0.0181293526;
    wave0 += sin(dot(p, float3(-5.838, -0.360, -1.536))) * 0.0175114826;
    wave1 += sin(dot(p, float3(-0.278, -4.565, 4.149))) * 0.0170799341;
    wave0 += sin(dot(p, float3(-5.893, -0.163, -2.141))) * 0.0167655258;
    wave1 += sin(dot(p, float3(4.855, -4.153, 0.606))) * 0.0163155335;
    wave0 += sin(dot(p, float3(4.498, 0.987, -4.488))) * 0.0162770287;
    wave1 += sin(dot(p, float3(-1.463, 5.321, -3.315))) * 0.0162569125;
    wave0 += sin(dot(p, float3(-1.862, 4.386, 4.749))) * 0.0154338176;
    wave1 += sin(dot(p, float3(0.563, 3.616, -5.751))) * 0.0151952226;
    wave0 += sin(dot(p, float3(-0.126, 2.569, -6.349))) * 0.0151089405;
    wave1 += sin(dot(p, float3(-5.094, 4.759, 0.186))) * 0.0147947096;
    wave0 += sin(dot(p, float3(1.319, 5.713, 3.845))) * 0.0147035221;
    wave1 += sin(dot(p, float3(7.141, -0.327, 1.420))) * 0.0140573910;
    wave0 += sin(dot(p, float3(3.888, 6.543, 0.547))) * 0.0133309850;
    wave1 += sin(dot(p, float3(-1.898, -3.563, -6.483))) * 0.0133171360;
    wave0 += sin(dot(p, float3(1.719, 7.769, 0.340))) * 0.0126913718;
    wave1 += sin(dot(p, float3(-2.210, -7.836, 0.102))) * 0.0123746071;
    wave0 += sin(dot(p, float3(6.248, -5.451, 1.866))) * 0.0117861898;
    wave1 += sin(dot(p, float3(1.627, -7.066, -4.732))) * 0.0115417453;
    wave0 += sin(dot(p, float3(4.099, -7.704, 1.474))) * 0.0112591564;
    wave1 += sin(dot(p, float3(7.357, 3.788, 3.204))) * 0.0112252325;
    wave0 += sin(dot(p, float3(-2.797, 6.208, 6.253))) * 0.0107206906;
    wave1 += sin(dot(p, float3(6.130, -5.335, -4.650))) * 0.0105693992;
    wave0 += sin(dot(p, float3(5.276, -5.576, -5.438))) * 0.0105139072;
    wave1 += sin(dot(p, float3(9.148, 2.530, -0.383))) * 0.0103996383;
    wave0 += sin(dot(p, float3(3.894, 2.559, 8.357))) * 0.0103161113;
    wave1 += sin(dot(p, float3(-6.604, 8.024, -0.289))) * 0.0094066875;
    wave0 += sin(dot(p, float3(-5.925, 6.505, -6.403))) * 0.0089444733;
    wave1 += sin(dot(p, float3(9.085, 10.331, -0.451))) * 0.0069245599;
    wave0 += sin(dot(p, float3(-8.228, 6.323, -9.900))) * 0.0066251015;
    wave1 += sin(dot(p, float3(10.029, -3.802, 12.151))) * 0.0058122824;
    wave0 += sin(dot(p, float3(-10.151, -6.513, -11.063))) * 0.0057522358;
    wave1 += sin(dot(p, float3(-1.773, -16.284, 2.828))) * 0.0056578101;
    wave0 += sin(dot(p, float3(11.081, 8.687, -9.852))) * 0.0054614334;
    wave1 += sin(dot(p, float3(-3.941, -4.386, 16.191))) * 0.0054454253;
    wave0 += sin(dot(p, float3(-6.742, 2.133, -17.268))) * 0.0050050132;
    wave1 += sin(dot(p, float3(-10.743, 5.698, 14.975))) * 0.0048323955;
    wave0 += sin(dot(p, float3(-9.603, 12.472, 14.542))) * 0.0043264378;
    wave1 += sin(dot(p, float3(13.515, 14.345, 8.481))) * 0.0043208884;
    wave0 += sin(dot(p, float3(-10.330, 16.209, -9.742))) * 0.0043013736;
    wave1 += sin(dot(p, float3(-8.580, -6.628, 19.191))) * 0.0042005922;
    wave0 += sin(dot(p, float3(-17.154, 10.620, 11.828))) * 0.0039482427;
    wave1 += sin(dot(p, float3(16.330, 14.123, -10.420))) * 0.0038474789;
    wave0 += sin(dot(p, float3(-21.275, 10.768, -3.252))) * 0.0038320501;
    wave1 += sin(dot(p, float3(1.744, 7.922, 23.152))) * 0.0037560829;
    wave0 += sin(dot(p, float3(-3.895, 21.321, 12.006))) * 0.0037173885;
    wave1 += sin(dot(p, float3(-22.705, 2.543, 10.695))) * 0.0036484394;
    wave0 += sin(dot(p, float3(-13.053, -16.634, -13.993))) * 0.0036291121;
    wave1 += sin(dot(p, float3(22.697, -11.230, 1.417))) * 0.0036280459;
    wave0 += sin(dot(p, float3(20.646, 14.602, 3.400))) * 0.0036055008;
    wave1 += sin(dot(p, float3(5.824, -8.717, -23.680))) * 0.0035501527;
    wave0 += sin(dot(p, float3(6.691, 15.499, 20.079))) * 0.0035029508;
    wave1 += sin(dot(p, float3(9.926, -22.778, 9.144))) * 0.0034694278;
    wave0 += sin(dot(p, float3(-9.552, -27.491, 2.197))) * 0.0031359281;
    wave1 += sin(dot(p, float3(21.071, -17.991, -11.566))) * 0.0030453280;
    wave0 += sin(dot(p, float3(9.780, 1.783, 28.536))) * 0.0030251754;
    wave1 += sin(dot(p, float3(8.738, -18.373, 22.725))) * 0.0029960272;
    wave0 += sin(dot(p, float3(14.105, 25.703, -8.834))) * 0.0029840058;
    wave1 += sin(dot(p, float3(-24.926, -17.766, -4.740))) * 0.0029487709;
    wave0 += sin(dot(p, float3(1.060, -1.570, 32.535))) * 0.0027980099;
    wave1 += sin(dot(p, float3(-24.532, -19.629, -16.759))) * 0.0025538949;
    wave0 += sin(dot(p, float3(28.772, -21.183, -9.935))) * 0.0024494819;
    wave1 += sin(dot(p, float3(-28.413, 22.959, 8.338))) * 0.0024236674;
    wave0 += sin(dot(p, float3(-27.664, 22.197, 13.301))) * 0.0023965996;
    wave1 += sin(dot(p, float3(-27.421, 20.643, 18.713))) * 0.0023203498;
    wave0 += sin(dot(p, float3(18.961, -7.189, 35.907))) * 0.0021967023;
    wave1 += sin(dot(p, float3(-23.949, 4.885, 33.762))) * 0.0021727461;
    wave0 += sin(dot(p, float3(35.305, 8.594, 20.564))) * 0.0021689816;
    wave1 += sin(dot(p, float3(30.364, -11.608, -27.199))) * 0.0021357139;
    wave0 += sin(dot(p, float3(34.268, 26.742, 0.958))) * 0.0020807976;
    wave1 += sin(dot(p, float3(-26.376, -17.313, -32.023))) * 0.0020108850;
    wave0 += sin(dot(p, float3(31.860, -32.181, -2.834))) * 0.0019919601;
    wave1 += sin(dot(p, float3(25.590, 32.340, 21.381))) * 0.0019446179;
    wave0 += sin(dot(p, float3(-17.771, -23.941, 37.324))) * 0.0018898258;
    wave1 += sin(dot(p, float3(-38.699, 19.953, -22.675))) * 0.0018379538;
    wave0 += sin(dot(p, float3(-46.284, 11.672, -15.411))) * 0.0017980056;
    wave1 += sin(dot(p, float3(-32.023, -43.976, -7.378))) * 0.0016399251;
    wave0 += sin(dot(p, float3(-42.390, -21.165, -31.889))) * 0.0015752176;
    wave1 += sin(dot(p, float3(-18.949, -40.461, 39.107))) * 0.0015141244;
    wave0 += sin(dot(p, float3(-21.507, -5.939, -58.531))) * 0.0014339601;
    wave1 += sin(dot(p, float3(-51.745, -43.821, 9.651))) * 0.0013096306;
    wave0 += sin(dot(p, float3(39.239, 25.971, -52.615))) * 0.0012701774;
    wave1 += sin(dot(p, float3(-49.669, -35.051, -36.306))) * 0.0012661695;
    wave0 += sin(dot(p, float3(-49.996, 35.309, 38.460))) * 0.0012398870;
    wave1 += sin(dot(p, float3(27.000, -65.904, -36.267))) * 0.0011199347;
    wave0 += sin(dot(p, float3(-52.523, -26.557, 57.693))) * 0.0010856391;
    wave1 += sin(dot(p, float3(-42.670, 0.269, -71.125))) * 0.0010786551;
    wave0 += sin(dot(p, float3(-9.377, 64.575, -68.151))) * 0.0009468199;
    wave1 += sin(dot(p, float3(14.571, -29.160, 106.329))) * 0.0008019719;
    wave0 += sin(dot(p, float3(-21.549, 103.887, 36.882))) * 0.0007939609;
    wave1 += sin(dot(p, float3(-42.781, 110.966, -9.070))) * 0.0007473261;
    wave0 += sin(dot(p, float3(-112.686, 18.296, -37.920))) * 0.0007409259;
    wave1 += sin(dot(p, float3(71.493, 33.838, -96.931))) * 0.0007121903;
    return wave0 + wave1;
}

float WoodNoiseGen_8_2(float3 p) {
    // This is a bit faster if we use 2 accumulators instead of 1.
    // Timed on Linux/Chrome/TitanX Pascal
    float wave0 = 0.0;
    float wave1 = 0.0;
    wave0 += sin(dot(p, float3(-1.490, -1.508, -0.788))) * 0.2643742568;
    wave1 += sin(dot(p, float3(1.932, -0.258, -1.358))) * 0.2372959116;
    wave0 += sin(dot(p, float3(2.637, -0.121, 0.524))) * 0.1833495728;
    wave1 += sin(dot(p, float3(2.349, 2.032, -1.499))) * 0.1154264791;
    wave0 += sin(dot(p, float3(0.246, 1.119, 3.271))) * 0.1144396416;
    wave1 += sin(dot(p, float3(-3.138, 0.351, 1.478))) * 0.1132573719;
    wave0 += sin(dot(p, float3(2.792, -1.067, -2.501))) * 0.0935422664;
    wave1 += sin(dot(p, float3(-3.272, -2.771, 0.610))) * 0.0785511933;
    return wave0 + wave1;
}

//8_7
float WoodNoiseGen(float3 p) {
    // This is a bit faster if we use 2 accumulators instead of 1.
    // Timed on Linux/Chrome/TitanX Pascal
    float wave0 = 0.0;
    float wave1 = 0.0;
    wave0 += sin(dot(p, float3(-2.146, -2.171, -1.135))) * 0.1278290488;
    wave1 += sin(dot(p, float3(3.297, -0.440, -2.317))) * 0.0875746437;
    wave0 += sin(dot(p, float3(7.141, -0.327, 1.420))) * 0.0355093026;
    wave1 += sin(dot(p, float3(16.330, 14.123, -10.420))) * 0.0070296152;
    wave0 += sin(dot(p, float3(1.744, 7.922, 23.152))) * 0.0068215049;
    wave1 += sin(dot(p, float3(-22.705, 2.543, 10.695))) * 0.0065780196;
    wave0 += sin(dot(p, float3(30.364, -11.608, -27.199))) * 0.0033681397;
    wave1 += sin(dot(p, float3(-51.745, -43.821, 9.651))) * 0.0018276677;
    return wave0 + wave1;
}

float WoodRepramp(float x) {
    return pow(sin(x) * 0.5 + 0.5, 8.0) + cos(x) * 0.7 + 0.7;
}

// Wood shader
float3 WoodColor(float3 pos)
{
    float rings = WoodRepramp(length(pos.xz + float2(WoodNoiseGen(pos * float3(8.0, 1.5, 8.0)), WoodNoiseGen(-pos * float3(8.0, 1.5, 8.0) + 4.5678)) * 0.05) * 64.0) / 1.8;
    rings -= WoodNoiseGen(pos * 1.0) * 0.75;
    float3 texColor = lerp(float3(0.3, 0.19, 0.075) * 0.95, float3(1.0, 0.73, 0.326) * 0.4, rings) * 1.5;
    texColor = max(0, texColor);
    float rough = (WoodNoiseGen(pos * 64.0 * float3(1.0, 0.2, 1.0)) * 0.1 + 0.9);
    texColor *= rough;
    texColor = saturate(texColor);
    return texColor;
}

float WoodDisplacement(float3 pos)
{
    float rings = WoodRepramp(length(pos.xz + float2(WoodNoiseGen(pos * float3(8.0, 1.5, 8.0)), WoodNoiseGen(-pos * float3(8.0, 1.5, 8.0) + 4.5678)) * 0.05) * 64.0) / 1.8;
    rings -= WoodNoiseGen(pos * 1.0) * 0.75;
    return rings;
}
#endif