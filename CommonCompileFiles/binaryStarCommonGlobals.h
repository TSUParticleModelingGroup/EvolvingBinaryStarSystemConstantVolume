//Globals for viewing
int XWindowSize = 1500;
int YWindowSize = 1500; 
	
//Viewing cropped pyrimid
double ViewBoxSize = 60.0;

GLdouble Left = -ViewBoxSize;
GLdouble Right = ViewBoxSize;
GLdouble Bottom = -ViewBoxSize;
GLdouble Top = ViewBoxSize;
GLdouble Front = ViewBoxSize;
GLdouble Back = -ViewBoxSize;

//Where your eye is located
GLdouble EyeX = 0.0;
GLdouble EyeY = 0.0;
GLdouble EyeZ = 5.0;

//Where you are looking
GLdouble CenterX = 0.0;
GLdouble CenterY = 0.0;
GLdouble CenterZ = 0.0;

//Up vector for viewing
GLdouble UpX = 0.0;
GLdouble UpY = 1.0;
GLdouble UpZ = 0.0;

//Globals to hold the time, positions, velocities, and forces on both the CPU to be read in from the start file.
float4 *PosCPU, *VelCPU, *ForceCPU;

//Globals to hold positions, velocities, and forces on both the GPU
float4 *PosGPU[4], *VelGPU[4], *ForceGPU[4];

//Globals to setup the kernals
dim3 BlockConfig, GridConfig;


//Globals to be readin from the RunParameters file
double SystemLengthConverterToKilometers;
double SystemMassConverterToKilograms;
double SystemTimeConverterToSeconds;
int NumberElementsStar1;
int NumberElementsStar2;
float CoreCorePushBackReduction, CorePlasmaPushBackReduction, PlasmaPlasmaPushBackReduction;

//Global to be built from run parameters
int NumberElements;

//Time step
float Dt;

//Lets you zoom in and zoom out.
double ZoomFactor;

//Draw rate
int DrawRate;

//How often to print the time to the termminal in days.
float PrintRate;


