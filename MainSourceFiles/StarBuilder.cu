/*
nvcc StarBuilder.cu -o StarBuilder.exe -lglut -lGL -lGLU -lm -arch=sm_60
nvcc StarBuilder.cu -o StarBuilder.exe -lglut -lGL -lGLU -lm -arch=compute_60 -code=sm_60
nvcc StarBuilder.cu -o StarBuilder.exe -lglut -lGL -lGLU -lm --use_fast_math
*/
#include "../CommonCompileFiles/binaryStarCommonIncludes.h"
#include "../CommonCompileFiles/binaryStarCommonDefines.h"
#include "../CommonCompileFiles/binaryStarCommonGlobals.h"
#include "../CommonCompileFiles/binaryStarCommonFunctions.h"

//Globals read in from the BiuldSetup file all except the number of elements will need to be put into our units
double MassOfStar1, DiameterStar1, MassOfCore1, DiameterCore1;
double MassOfStar2, DiameterStar2, MassOfCore2, DiameterCore2;
float4 InitialSpin1, InitialSpin2;

//These next 4 do not need to be globals in the run files because they are store in the elements
double PressurePlasma1;				
double PressurePlasma2;
double PushBackCoreMult1;
double PushBackCoreMult2;

double MaxInitialPlasmaSpeed;
				
double RedGiantVolumeGrowth;

double RawStarDampAmount;
double RawStarDampTime;
int RawStarDampLevels;
double RawStarRestTime;

double DiameterTolerance;
double DiameterAdjustmentSoftener;
double DiameterAdjustmentDamp;
double DiameterAdjustmentTime;
double DiameterAdjustmentRestTime;

double SpinRestTime;

void createFolderForNewStars()
{   	
	//Create output folder to store the stars
	time_t t = time(0); 
	struct tm * now = localtime( & t );
	int month = now->tm_mon + 1, day = now->tm_mday, curTimeHour = now->tm_hour, curTimeMin = now->tm_min;
	stringstream smonth, sday, stimeHour, stimeMin;
	smonth << month;
	sday << day;
	stimeHour << curTimeHour;
	stimeMin << curTimeMin;
	string monthday;
	if (curTimeMin <= 9)	monthday = smonth.str() + "-" + sday.str() + "-" + stimeHour.str() + ":0" + stimeMin.str();
	else			monthday = smonth.str() + "-" + sday.str() + "-" + stimeHour.str() + ":" + stimeMin.str();
	string foldernametemp = "Stars:" + monthday;
	const char *starFolderName = foldernametemp.c_str();
	mkdir(starFolderName , S_IRWXU|S_IRWXG|S_IRWXO);
	
	FILE *fileIn;
	FILE *fileOut;
	long sizeOfFile;
  	char *buffer;
  	
  	//Moving into the new directory and creating folders.
  	chdir(starFolderName);
  	mkdir("FilesFromBuild" , S_IRWXU|S_IRWXG|S_IRWXO);
  	mkdir("CommonCompileFiles" , S_IRWXU|S_IRWXG|S_IRWXO);
  	mkdir("MainSourceFiles" , S_IRWXU|S_IRWXG|S_IRWXO);
  	mkdir("ExecutableFiles" , S_IRWXU|S_IRWXG|S_IRWXO);
  	mkdir("ContinueFiles" , S_IRWXU|S_IRWXG|S_IRWXO);
    
    	//Copying the files that were used to build the raw stars into the star folder.
    	//BuildSteup file
	fileIn = fopen("../BuildSetup", "rb");
	if(fileIn == NULL)
	{
		printf("\n\n The BuildSetup file does not exist\n\n");
		exit(0);
	}
	fseek (fileIn , 0 , SEEK_END);
  	sizeOfFile = ftell(fileIn);
  	rewind (fileIn);
  	buffer = (char*)malloc(sizeof(char)*sizeOfFile);
  	fread (buffer, 1, sizeOfFile, fileIn);
	fileOut = fopen("FilesFromBuild/BuildSetup", "wb");
	fwrite (buffer, 1, sizeOfFile, fileOut);
	fclose(fileIn);
	fclose(fileOut);
	
	fileIn = fopen("../CommonCompileFiles/binaryStarCommonIncludes.h", "rb");
	if(fileIn == NULL)
	{
		printf("\n\n The CommonCompileFiles/binaryStarCommonIncludes.h file does not exist\n\n");
		exit(0);
	}
	fseek (fileIn , 0 , SEEK_END);
  	sizeOfFile = ftell(fileIn);
  	rewind (fileIn);
  	buffer = (char*)malloc(sizeof(char)*sizeOfFile);
  	fread (buffer, 1, sizeOfFile, fileIn);
	fileOut = fopen("CommonCompileFiles/binaryStarCommonIncludes.h", "wb");
	fwrite (buffer, 1, sizeOfFile, fileOut);
	fclose(fileIn);
	fclose(fileOut);
	
	fileIn = fopen("../CommonCompileFiles/binaryStarCommonDefines.h", "rb");
	if(fileIn == NULL)
	{
		printf("\n\n The CommonCompileFiles/binaryStarCommonDefines.h file does not exist\n\n");
		exit(0);
	}
	fseek (fileIn , 0 , SEEK_END);
  	sizeOfFile = ftell(fileIn);
  	rewind (fileIn);
  	buffer = (char*)malloc(sizeof(char)*sizeOfFile);
  	fread (buffer, 1, sizeOfFile, fileIn);
	fileOut = fopen("CommonCompileFiles/binaryStarCommonDefines.h", "wb");
	fwrite (buffer, 1, sizeOfFile, fileOut);
	fclose(fileIn);
	fclose(fileOut);
	
	fileIn = fopen("../CommonCompileFiles/binaryStarCommonGlobals.h", "rb");
	if(fileIn == NULL)
	{
		printf("\n\n The CommonCompileFiles/binaryStarCommonGlobals.h file does not exist\n\n");
		exit(0);
	}
	fseek (fileIn , 0 , SEEK_END);
  	sizeOfFile = ftell(fileIn);
  	rewind (fileIn);
  	buffer = (char*)malloc(sizeof(char)*sizeOfFile);
  	fread (buffer, 1, sizeOfFile, fileIn);
	fileOut = fopen("CommonCompileFiles/binaryStarCommonGlobals.h", "wb");
	fwrite (buffer, 1, sizeOfFile, fileOut);
	fclose(fileIn);
	fclose(fileOut);
	
	fileIn = fopen("../CommonCompileFiles/binaryStarCommonFunctions.h", "rb");
	if(fileIn == NULL)
	{
		printf("\n\n The CommonCompileFiles/binaryStarCommonFunctions.h file does not exist\n\n");
		exit(0);
	}
	fseek (fileIn , 0 , SEEK_END);
  	sizeOfFile = ftell(fileIn);
  	rewind (fileIn);
  	buffer = (char*)malloc(sizeof(char)*sizeOfFile);
  	fread (buffer, 1, sizeOfFile, fileIn);
	fileOut = fopen("CommonCompileFiles/binaryStarCommonFunctions.h", "wb");
	fwrite (buffer, 1, sizeOfFile, fileOut);
	fclose(fileIn);
	fclose(fileOut);
	
	fileIn = fopen("../CommonCompileFiles/binaryStarCommonRunGlobals.h", "rb");
	if(fileIn == NULL)
	{
		printf("\n\n The CommonCompileFiles/binaryStarCommonRunGlobals.h file does not exist\n\n");
		exit(0);
	}
	fseek (fileIn , 0 , SEEK_END);
  	sizeOfFile = ftell(fileIn);
  	rewind (fileIn);
  	buffer = (char*)malloc(sizeof(char)*sizeOfFile);
  	fread (buffer, 1, sizeOfFile, fileIn);
	fileOut = fopen("CommonCompileFiles/binaryStarCommonRunGlobals.h", "wb");
	fwrite (buffer, 1, sizeOfFile, fileOut);
	fclose(fileIn);
	fclose(fileOut);
	
	fileIn = fopen("../CommonCompileFiles/binaryStarCommonRunFunctions.h", "rb");
	if(fileIn == NULL)
	{
		printf("\n\n The CommonCompileFiles/binaryStarCommonRunFunctions.h file does not exist\n\n");
		exit(0);
	}
	fseek (fileIn , 0 , SEEK_END);
  	sizeOfFile = ftell(fileIn);
  	rewind (fileIn);
  	buffer = (char*)malloc(sizeof(char)*sizeOfFile);
  	fread (buffer, 1, sizeOfFile, fileIn);
	fileOut = fopen("CommonCompileFiles/binaryStarCommonRunFunctions.h", "wb");
	fwrite (buffer, 1, sizeOfFile, fileOut);
	fclose(fileIn);
	fclose(fileOut);
	
	//Main source files
	fileIn = fopen("../MainSourceFiles/StarBuilder.cu", "rb");
	if(fileIn == NULL)
	{
		printf("\n\n The MainSourceFiles/StarBuilder.cu file does not exist\n\n");
		exit(0);
	}
	fseek (fileIn , 0 , SEEK_END);
  	sizeOfFile = ftell(fileIn);
  	rewind (fileIn);
  	buffer = (char*)malloc(sizeof(char)*sizeOfFile);
  	fread (buffer, 1, sizeOfFile, fileIn);
	fileOut = fopen("MainSourceFiles/StarBuilder.cu", "wb");
	fwrite (buffer, 1, sizeOfFile, fileOut);
	fclose(fileIn);
	fclose(fileOut);
	
	fileIn = fopen("../MainSourceFiles/StarBranchRun.cu", "rb");
	if(fileIn == NULL)
	{
		printf("\n\n The MainSourceFiles/StarBranchRun.cu file does not exist\n\n");
		exit(0);
	}
	fseek (fileIn , 0 , SEEK_END);
  	sizeOfFile = ftell(fileIn);
  	rewind (fileIn);
  	buffer = (char*)malloc(sizeof(char)*sizeOfFile);
  	fread (buffer, 1, sizeOfFile, fileIn);
	fileOut = fopen("MainSourceFiles/StarBranchRun.cu", "wb");
	fwrite (buffer, 1, sizeOfFile, fileOut);
	fclose(fileIn);
	fclose(fileOut);
	
	fileIn = fopen("../MainSourceFiles/StarContinueRun.cu", "rb");
	if(fileIn == NULL)
	{
		printf("\n\n The MainSourceFiles/StarContinueRun.cu file does not exist\n\n");
		exit(0);
	}
	fseek (fileIn , 0 , SEEK_END);
  	sizeOfFile = ftell(fileIn);
  	rewind (fileIn);
  	buffer = (char*)malloc(sizeof(char)*sizeOfFile);
  	fread (buffer, 1, sizeOfFile, fileIn);
	fileOut = fopen("MainSourceFiles/StarContinueRun.cu", "wb");
	fwrite (buffer, 1, sizeOfFile, fileOut);
	fclose(fileIn);
	fclose(fileOut);
	
	fileIn = fopen("../MainSourceFiles/Viewer.cu", "rb");
	if(fileIn == NULL)
	{
		printf("\n\n The MainSourceFiles/Viewer.cu file does not exist\n\n");
		exit(0);
	}
	fseek (fileIn , 0 , SEEK_END);
  	sizeOfFile = ftell(fileIn);
  	rewind (fileIn);
  	buffer = (char*)malloc(sizeof(char)*sizeOfFile);
  	fread (buffer, 1, sizeOfFile, fileIn);
	fileOut = fopen("MainSourceFiles/Viewer.cu", "wb");
	fwrite (buffer, 1, sizeOfFile, fileOut);
	fclose(fileIn);
	fclose(fileOut);
	
	//Executable files
	fileIn = fopen("../ExecutableFiles/StarBuilder.exe", "rb");
	if(fileIn == NULL)
	{
		printf("\n\n The ExecutableFiles/StarBuilder.exe file does not exist\n\n");
		exit(0);
	}
	fseek (fileIn , 0 , SEEK_END);
  	sizeOfFile = ftell(fileIn);
  	rewind (fileIn);
  	buffer = (char*)malloc(sizeof(char)*sizeOfFile);
  	fread (buffer, 1, sizeOfFile, fileIn);
	fileOut = fopen("ExecutableFiles/StarBuilder.exe", "wb");
	fwrite (buffer, 1, sizeOfFile, fileOut);
	fclose(fileIn);
	fclose(fileOut);
	
	fileIn = fopen("../ExecutableFiles/StarBranchRun.exe", "rb");
	if(fileIn == NULL)
	{
		printf("\n\n The ExecutableFiles/StarBranchRun.exe file does not exist\n\n");
		exit(0);
	}
	fseek (fileIn , 0 , SEEK_END);
  	sizeOfFile = ftell(fileIn);
  	rewind (fileIn);
  	buffer = (char*)malloc(sizeof(char)*sizeOfFile);
  	fread (buffer, 1, sizeOfFile, fileIn);
	fileOut = fopen("ExecutableFiles/StarBranchRun.exe", "wb");
	fwrite (buffer, 1, sizeOfFile, fileOut);
	fclose(fileIn);
	fclose(fileOut);
	
	fileIn = fopen("../ExecutableFiles/StarContinueRun.exe", "rb");
	if(fileIn == NULL)
	{
		printf("\n\n The ExecutableFiles/StarContinueRun.exe file does not exist\n\n");
		exit(0);
	}
	fseek (fileIn , 0 , SEEK_END);
  	sizeOfFile = ftell(fileIn);
  	rewind (fileIn);
  	buffer = (char*)malloc(sizeof(char)*sizeOfFile);
  	fread (buffer, 1, sizeOfFile, fileIn);
	fileOut = fopen("ExecutableFiles/StarContinueRun.exe", "wb");
	fwrite (buffer, 1, sizeOfFile, fileOut);
	fclose(fileIn);
	fclose(fileOut);
	
	fileIn = fopen("../ExecutableFiles/Viewer.exe", "rb");
	if(fileIn == NULL)
	{
		printf("\n\n The ExecutableFiles/Viewer.exe file does not exist\n\n");
		exit(0);
	}
	fseek (fileIn , 0 , SEEK_END);
  	sizeOfFile = ftell(fileIn);
  	rewind (fileIn);
  	buffer = (char*)malloc(sizeof(char)*sizeOfFile);
  	fread (buffer, 1, sizeOfFile, fileIn);
	fileOut = fopen("ExecutableFiles/Viewer.exe", "wb");
	fwrite (buffer, 1, sizeOfFile, fileOut);
	fclose(fileIn);
	fclose(fileOut);
	
	//Copying files into the main branch folder	
	fileIn = fopen("../BranchAndContinueFiles/BranchRun", "rb");
	if(fileIn == NULL)
	{
		printf("\n\n The BranchAndContinueFiles/BranchRun file does not exist\n\n");
		exit(0);
	}
	fseek (fileIn , 0 , SEEK_END);
  	sizeOfFile = ftell(fileIn);
  	rewind (fileIn);
  	buffer = (char*)malloc(sizeof(char)*sizeOfFile);
  	fread (buffer, 1, sizeOfFile, fileIn);
	fileOut = fopen("BranchRun", "wb");
	fwrite (buffer, 1, sizeOfFile, fileOut);
	fclose(fileIn);
	fclose(fileOut);
	
	//We will also copy the branch run source code and put it in the main branch folder and the BranchSetupTemplate.
	fileIn = fopen("../BranchAndContinueFiles/BranchSetupTemplate", "rb");
	if(fileIn == NULL)
	{
		printf("\n\n The BranchAndContinueFiles/BranchSetupTemplate file does not exist\n\n");
		exit(0);
	}
	fseek (fileIn , 0 , SEEK_END);
  	sizeOfFile = ftell(fileIn);
  	rewind (fileIn);
  	buffer = (char*)malloc(sizeof(char)*sizeOfFile);
  	fread (buffer, 1, sizeOfFile, fileIn);
	fileOut = fopen("BranchSetup", "wb");
	fwrite (buffer, 1, sizeOfFile, fileOut);
	fclose(fileIn);
	fclose(fileOut);
	
	//Finally copying the continue run script and viewer into the ContinueFiles foldes
	fileIn = fopen("../BranchAndContinueFiles/ContinueRun", "rb");
	if(fileIn == NULL)
	{
		printf("\n\n The BranchAndContinueFiles/ContinueRun file does not exist\n\n");
		exit(0);
	}
	fseek (fileIn , 0 , SEEK_END);
  	sizeOfFile = ftell(fileIn);
  	rewind (fileIn);
  	buffer = (char*)malloc(sizeof(char)*sizeOfFile);
  	fread (buffer, 1, sizeOfFile, fileIn);
	fileOut = fopen("ContinueFiles/ContinueRun", "wb");
	fwrite (buffer, 1, sizeOfFile, fileOut);
	fclose(fileIn);
	fclose(fileOut);
	
	fileIn = fopen("../BranchAndContinueFiles/Viewer", "rb");
	if(fileIn == NULL)
	{
		printf("\n\n The BranchAndContinueFiles/Viewer file does not exist\n\n");
		exit(0);
	}
	fseek (fileIn , 0 , SEEK_END);
  	sizeOfFile = ftell(fileIn);
  	rewind (fileIn);
  	buffer = (char*)malloc(sizeof(char)*sizeOfFile);
  	fread (buffer, 1, sizeOfFile, fileIn);
	fileOut = fopen("ContinueFiles/Viewer", "wb");
	fwrite (buffer, 1, sizeOfFile, fileOut);
	fclose(fileIn);
	fclose(fileOut);

	free (buffer);
	
	//Giving the apropriate file execute permisions. I didn't give the starBuild execute permision because it 
	//should only be used in the main folder. This file is only for reference.
	system("chmod 755 ./ExecutableFiles/StarBranchRun.exe");
	system("chmod 755 ./ExecutableFiles/StarContinueRun.exe");
	system("chmod 755 ./ExecutableFiles/Viewer.exe");
	system("chmod 755 ./BranchRun");
}

void readBuildParameters()
{
	ifstream data;
	string name;
	
	data.open("../BuildSetup");
	
	if(data.is_open() == 1)
	{
		getline(data,name,'=');
		data >> DiameterStar1;
		getline(data,name,'=');
		data >> DiameterCore1;
		getline(data,name,'=');
		data >> DiameterStar2;
		getline(data,name,'=');
		data >> DiameterCore2;
		
		getline(data,name,'=');
		data >> MassOfStar1;
		getline(data,name,'=');
		data >> MassOfCore1;
		getline(data,name,'=');
		data >> MassOfStar2;
		getline(data,name,'=');
		data >> MassOfCore2;
		
		getline(data,name,'=');
		data >> NumberElements;
		
		getline(data,name,'=');
		data >> InitialSpin1.x;
		getline(data,name,'=');
		data >> InitialSpin1.y;
		getline(data,name,'=');
		data >> InitialSpin1.z;
		getline(data,name,'=');
		data >> InitialSpin1.w;
		
		getline(data,name,'=');
		data >> InitialSpin2.x;
		getline(data,name,'=');
		data >> InitialSpin2.y;
		getline(data,name,'=');
		data >> InitialSpin2.z;
		getline(data,name,'=');
		data >> InitialSpin2.w;
		
		getline(data,name,'=');
		data >> PressurePlasma1;
		getline(data,name,'=');
		data >> PressurePlasma2;
		
		getline(data,name,'=');
		data >> PushBackCoreMult1;
		getline(data,name,'=');
		data >> PushBackCoreMult2;
		
		getline(data,name,'=');
		data >> CoreCorePushBackReduction;
		getline(data,name,'=');
		data >> CorePlasmaPushBackReduction;
		getline(data,name,'=');
		data >> PlasmaPlasmaPushBackReduction;
		
		getline(data,name,'=');
		data >> MaxInitialPlasmaSpeed;
		
		getline(data,name,'=');
		data >> RedGiantVolumeGrowth;
		
		getline(data,name,'=');
		data >> RawStarDampAmount;
		getline(data,name,'=');
		data >> RawStarDampTime;
		getline(data,name,'=');
		data >> RawStarDampLevels;
		getline(data,name,'=');
		data >> RawStarRestTime;
		
		getline(data,name,'=');
		data >> DiameterTolerance;
		getline(data,name,'=');
		data >> DiameterAdjustmentSoftener;
		getline(data,name,'=');
		data >> DiameterAdjustmentDamp;
		getline(data,name,'=');
		data >> DiameterAdjustmentTime;
		getline(data,name,'=');
		data >> DiameterAdjustmentRestTime;
		
		getline(data,name,'=');
		data >> SpinRestTime;
		
		getline(data,name,'=');
		data >> Dt;
		
		getline(data,name,'=');
		data >> ZoomFactor;
		
		getline(data,name,'=');
		data >> DrawRate;
		
		getline(data,name,'=');
		data >> PrintRate;
		
		getline(data,name,'=');
		data >> Core1Color.x;
		getline(data,name,'=');
		data >> Core1Color.y;
		getline(data,name,'=');
		data >> Core1Color.z;
		
		getline(data,name,'=');
		data >> Core2Color.x;
		getline(data,name,'=');
		data >> Core2Color.y;
		getline(data,name,'=');
		data >> Core2Color.z;
		
		getline(data,name,'=');
		data >> Envelope1Color.x;
		getline(data,name,'=');
		data >> Envelope1Color.y;
		getline(data,name,'=');
		data >> Envelope1Color.z;
		
		getline(data,name,'=');
		data >> Envelope2Color.x;
		getline(data,name,'=');
		data >> Envelope2Color.y;
		getline(data,name,'=');
		data >> Envelope2Color.z;
	}
	else
	{
		printf("\nTSU Error could not open BuildSetup file\n");
		exit(0);
	}
	data.close();
}

//This function sets the units such that the mass unit is the mass of a plasma element, 
//the length unit is the diameter of a plasma element and time unit such that G is 1.
//It also splits the number of elements between the stars and creates convetion factors to standard units.
void generateAndSaveRunParameters()
{
	double massPlasmaElement;
	double diameterPlasmaElement;
	double totalMassPlasmaElements;
	
	MassOfStar1 *= MASS_SUN;
	MassOfStar2 *= MASS_SUN;
	MassOfCore1 *= MASS_SUN;
	MassOfCore2 *= MASS_SUN;
	DiameterStar1 *= DIAMETER_SUN;
	DiameterStar2 *= DIAMETER_SUN;
	DiameterCore1 *= DIAMETER_SUN;
	DiameterCore2 *= DIAMETER_SUN;
	
	totalMassPlasmaElements = (MassOfStar1 - MassOfCore1) + (MassOfStar2 - MassOfCore2);
	
	//The mass of a plasma element is just the total mass divided by the number of elements used. Need to subtract 2 because you have 2 cores.
	massPlasmaElement = totalMassPlasmaElements/((double)NumberElements - 2);
	
	//We will use the mass of a plasma element as one unit of mass. 
	//The following constant will convert system masses up to kilograms by multipling 
	//or convert kilograms down to system units by dividing.
	SystemMassConverterToKilograms = massPlasmaElement;
	
	//Dividing up the plasma elements between the 2 stars.
	//Need to subtract 2 because you have 2 core elements.
	NumberElementsStar1 = ((MassOfStar1 - MassOfCore1)/totalMassPlasmaElements)*((double)NumberElements - 2);
	NumberElementsStar2 = (NumberElements -2) - NumberElementsStar1;
	//Adding back the core elements.
	NumberElementsStar1 += 1;
	NumberElementsStar2 += 1;
	
	//Finding the diameter of the plasma elements is a bit more involved. First find the volume of the plasma Vpl = Vsun - Vcore.
	double volumePlasma = (4.0*PI/3.0)*( pow((DiameterStar1/2.0),3.0) - pow((DiameterCore1/2.0),3.0) ) + (4.0*PI/3.0)*( pow((DiameterStar2/2.0),3.0) - pow((DiameterCore2/2.0),3.0) );
	//Now randum spheres only pack at 68 persent so to adjust for this we need to adjust for this.
	volumePlasma *= 0.68;
	//Now this is the volume the plasma but we would the star to grow in size by up 100 times. 
	//I'm assuming when they this they mean volume. I will also make the amount it can grow a #define so it can be changed easily.
	volumePlasma = volumePlasma*RedGiantVolumeGrowth;
	//Now to find the volume of a plasma element divide this by the number of plasma elements.
	double volumePlasmaElement = volumePlasma/(NumberElements -2);
	//Now to find the diameter of a plasma element we need to find the diameter to make this volume.
	diameterPlasmaElement = pow(6.0*volumePlasmaElement/PI, (1.0/3.0));
	
	//We will use the diameter of a plasma element as one unit of length. 
	//The following constant will convert system lengths up to kilometers by multipling 
	//or convert kilometers down to system units by dividing.
	SystemLengthConverterToKilometers = diameterPlasmaElement;
	
	//We will use a time unit so that the universal gravitational constant will be 1. 
	//The following constant will convert system times up to seconds by multipling 
	//or convert seconds down to system units by dividing. Make sure UniversalGravity is fed into the program in kilograms kilometers and seconds!
	SystemTimeConverterToSeconds = sqrt(pow(SystemLengthConverterToKilometers,3)/(SystemMassConverterToKilograms*UNIVERSAL_GRAVITY_CONSTANT));
	
	//Putting things with mass into our units. Taking kilograms into our units.
	MassOfStar1 /= SystemMassConverterToKilograms;
	MassOfCore1 /= SystemMassConverterToKilograms;
	MassOfStar2 /= SystemMassConverterToKilograms;
	MassOfCore2 /= SystemMassConverterToKilograms;
	
	//Putting things with length into our units. Taking kilometers into our units.
	DiameterStar1 /= SystemLengthConverterToKilometers;
	DiameterCore1 /= SystemLengthConverterToKilometers;
	DiameterStar2 /= SystemLengthConverterToKilometers;
	DiameterCore2 /= SystemLengthConverterToKilometers;
	
	//Putting things with time into our units.
	Dt *= (3600.0/SystemTimeConverterToSeconds); //It was in hours so take it to seconds first.
	RawStarDampTime *= (24.0*3600.0/SystemTimeConverterToSeconds); //It was in days so take it to seconds first. 
	RawStarRestTime *= (24.0*3600.0/SystemTimeConverterToSeconds); //It was in days so take it to seconds first.
	DiameterAdjustmentTime *= (24.0*3600.0/SystemTimeConverterToSeconds); //It was in days so take it to seconds first.
	DiameterAdjustmentRestTime *= (24.0*3600.0/SystemTimeConverterToSeconds); //It was in days so take it to seconds first.
	SpinRestTime *= (24.0*3600.0/SystemTimeConverterToSeconds); //It was in days so take it to seconds first.
	PrintRate *= (24.0*3600.0/SystemTimeConverterToSeconds); //It was in days so take it to seconds first.
	
	//Putting Angular Velocities into our units. Taking revolutions/hour into our units. Must take it to seconds first.
	InitialSpin1.w *= SystemTimeConverterToSeconds/3600.0;
	InitialSpin2.w *= SystemTimeConverterToSeconds/3600.0;
	
	//Putting push back parameters into our units. kilograms*kilometersE-1*secondsE-2 into our units.
	//This will be multiplied by an area to make it a force
	PressurePlasma1 /= SystemMassConverterToKilograms/(SystemTimeConverterToSeconds*SystemTimeConverterToSeconds*SystemLengthConverterToKilometers);
	PressurePlasma2 /= SystemMassConverterToKilograms/(SystemTimeConverterToSeconds*SystemTimeConverterToSeconds*SystemLengthConverterToKilometers);
	
	FILE *runParametersFile;
	runParametersFile = fopen("FilesFromBuild/RunParameters", "wb");
		fprintf(runParametersFile, "\n SystemLengthConverterToKilometers = %e", SystemLengthConverterToKilometers);
		fprintf(runParametersFile, "\n SystemMassConverterToKilograms = %e", SystemMassConverterToKilograms);
		fprintf(runParametersFile, "\n SystemTimeConverterToSeconds = %e", SystemTimeConverterToSeconds);
	
		fprintf(runParametersFile, "\n NumberElementsStar1 = %d", NumberElementsStar1);
		fprintf(runParametersFile, "\n NumberElementsStar2 = %d", NumberElementsStar2);
		fprintf(runParametersFile, "\n Core Core Push Back Reduction = %f", CoreCorePushBackReduction);
		fprintf(runParametersFile, "\n Core Plasma Push Back Reduction = %f", CorePlasmaPushBackReduction);
		fprintf(runParametersFile, "\n Plasma Plasma Push Back Reduction = %f", PlasmaPlasmaPushBackReduction);
		fprintf(runParametersFile, "\n Time step Dt = %f", Dt);
		fprintf(runParametersFile, "\n Zoom factor = %f", ZoomFactor);
		fprintf(runParametersFile, "\n Print rate = %f", PrintRate);
		fprintf(runParametersFile, "\n Core1Color.x = %f", Core1Color.x);
		fprintf(runParametersFile, "\n Core1Color.y = %f", Core1Color.y);
		fprintf(runParametersFile, "\n Core1Color.z = %f", Core1Color.z);
		fprintf(runParametersFile, "\n Core2Color.x = %f", Core2Color.x);
		fprintf(runParametersFile, "\n Core2Color.y = %f", Core2Color.y);
		fprintf(runParametersFile, "\n Core2Color.z = %f", Core2Color.z);
		fprintf(runParametersFile, "\n Envelope1Color.x = %f", Envelope1Color.x);
		fprintf(runParametersFile, "\n Envelope1Color.y = %f", Envelope1Color.y);
		fprintf(runParametersFile, "\n Envelope1Color.z = %f", Envelope1Color.z);
		fprintf(runParametersFile, "\n Envelope2Color.x = %f", Envelope2Color.x);
		fprintf(runParametersFile, "\n Envelope2Color.y = %f", Envelope2Color.y);
		fprintf(runParametersFile, "\n Envelope2Color.z = %f", Envelope2Color.z);
		fprintf(runParametersFile, "\n RadiusCore1 = %f", DiameterCore1/2.0);
		fprintf(runParametersFile, "\n RadiusCore2 = %f", DiameterCore2/2.0);
	fclose(runParametersFile);
}

int createRawStar(int starNumber)
{
	//int cubeStart;
	int elementStart, elementStop;
	int element, cubeLayer;
	int x, y, z;
	double elementMass, elementDiameter, elementPressure;
	double mag, speed, seperation;
	time_t t;
	
	if(starNumber == 1)
	{
		elementStart = 0;
		elementStop = NumberElementsStar1;
		elementMass = 1.0; // The mass unit was set so 1 is the mass of an element.
		elementDiameter = 1.0; // The length unit was set so 1 is the diameter of an element.
		elementPressure = PressurePlasma1;
		PosCPU[0].x = 0.0;
		PosCPU[0].y = 0.0;
		PosCPU[0].z = 0.0;
		PosCPU[0].w = MassOfCore1;
		VelCPU[0].x = 0.0;
		VelCPU[0].y = 0.0;
		VelCPU[0].z = 0.0;
		VelCPU[0].w = PushBackCoreMult1;
		ForceCPU[0].x = 0.0;
		ForceCPU[0].y = 0.0;
		ForceCPU[0].z = 0.0;
		ForceCPU[0].w = DiameterCore1;
		if(DiameterCore2 < elementDiameter)
		{
			cubeLayer = elementDiameter ;
		}
		else
		{
			cubeLayer = (int)DiameterCore1 + 1; // This is the size of the cube the core takes up. Added 1 to be safe.
		}
		element = elementStart + 1; //Add 1 because the core is the first element.
	}
	if(starNumber == 2)
	{
		elementStart = NumberElementsStar1;
		elementStop = NumberElements; 
		elementMass = 1.0; // The mass unit was set so 1 is the mass of an element.
		elementDiameter = 1.0; // The length unit was set so 1 is the diameter of an element.
		elementPressure = PressurePlasma2;
		PosCPU[NumberElementsStar1].x = 0.0;
		PosCPU[NumberElementsStar1].y = 0.0;
		PosCPU[NumberElementsStar1].z = 0.0;
		PosCPU[NumberElementsStar1].w = MassOfCore2;
		VelCPU[NumberElementsStar1].x = 0.0;
		VelCPU[NumberElementsStar1].y = 0.0;
		VelCPU[NumberElementsStar1].z = 0.0;
		VelCPU[NumberElementsStar1].w = PushBackCoreMult2;
		ForceCPU[NumberElementsStar1].x = 0.0;
		ForceCPU[NumberElementsStar1].y = 0.0;
		ForceCPU[NumberElementsStar1].z = 0.0;
		ForceCPU[NumberElementsStar1].w = DiameterCore2;
		if(DiameterCore2 < elementDiameter)
		{
			cubeLayer = elementDiameter;
		}
		else
		{
			cubeLayer = (int)DiameterCore2 + 1; // This is the size of the cube the core takes up. Added 1 to be safe.
		}
		element = elementStart + 1; //Add 1 because the core is the first element.
	}
	
	// The core is at (0,0,0) we then place elements in a cubic grid around it. Each element radius is 1 so we will walk out in units of 1.    
	while(element < elementStop)
	{
		cubeLayer++;
		x = -cubeLayer;
		for(y = -cubeLayer; y <= cubeLayer; y++)
		{
			for(z = -cubeLayer; z <= cubeLayer; z++)
			{
				if(element < elementStop)
				{
					PosCPU[element].x = (float)x;
					PosCPU[element].y = (float)y;
					PosCPU[element].z = (float)z;
					PosCPU[element].w = elementMass;
					element++;
				}
				else break;
			}
		}
	
		x = cubeLayer;
		for(y = -cubeLayer; y <= cubeLayer; y++)
		{
			for(z = -cubeLayer; z <= cubeLayer; z++)
			{
				if(element < elementStop)
				{
					PosCPU[element].x = (float)x;
					PosCPU[element].y = (float)y;
					PosCPU[element].z = (float)z;
					PosCPU[element].w = elementMass;
					element++;
				}
				else break;
			}
		}
	
		y = -cubeLayer;
		for(x = -cubeLayer + 1; x <= cubeLayer - 1; x++)
		{
			for(z = -cubeLayer; z <= cubeLayer; z++)
			{
				if(element < elementStop)
				{
					PosCPU[element].x = (float)x;
					PosCPU[element].y = (float)y;
					PosCPU[element].z = (float)z;
					PosCPU[element].w = elementMass;
					element++;
				}
				else break;
			}
		}
	
		y = cubeLayer;
		for(x = -cubeLayer + 1; x <= cubeLayer - 1; x++)
		{
			for(z = -cubeLayer; z <= cubeLayer; z++)
			{
				if(element < elementStop)
				{
					PosCPU[element].x = (float)x;
					PosCPU[element].y = (float)y;
					PosCPU[element].z = (float)z;
					PosCPU[element].w = elementMass;
					element++;
				}
				else break;
			}
		}
	
		z = -cubeLayer;
		for(x = -cubeLayer + 1; x <= cubeLayer - 1; x++)
		{
			for(y = -cubeLayer + 1; y <= cubeLayer - 1; y++)
			{
				if(element < elementStop)
				{
					PosCPU[element].x = (float)x;
					PosCPU[element].y = (float)y;
					PosCPU[element].z = (float)z;
					PosCPU[element].w = elementMass;
					element++;
				}
				else break;
			}
		}
	
		z = cubeLayer;
		for(x = -cubeLayer + 1; x <= cubeLayer - 1; x++)
		{
			for(y = -cubeLayer + 1; y <= cubeLayer - 1; y++)
			{
				if(element < elementStop)
				{
					PosCPU[element].x = (float)x;
					PosCPU[element].y = (float)y;
					PosCPU[element].z = (float)z;
					PosCPU[element].w = elementMass;
					element++;
				}
				else break;
			}
		}
	}
	
	//Just checking to make sure I didn't put any elements on top of each other.
	for(int i = elementStart; i < elementStop; i++)
	{
		for(int j = elementStart; j < elementStop; j++)
		{
			if(i != j)
			{
				seperation = sqrt((PosCPU[i].x - PosCPU[j].x)*(PosCPU[i].x - PosCPU[j].x)
					   + (PosCPU[i].y - PosCPU[j].y)*(PosCPU[i].y - PosCPU[j].y)
					   + (PosCPU[i].z - PosCPU[j].z)*(PosCPU[i].z - PosCPU[j].z));
				if(seperation < ASSUME_ZERO_DOUBLE)
				{
					printf("\n TSU error: Two elements are on top of each other in the creatRawStars function\n");
					exit(0);
				}
			}
			else break;
		}
	}
	
	// Setting the randum number generater seed.
	srand((unsigned) time(&t));
	
	// Giving each noncore particle a randium velocity to shake things up a little. Also setting the pushback and diameter of noncore particles.
	speed = MaxInitialPlasmaSpeed/SystemLengthConverterToKilometers/SystemTimeConverterToSeconds;
	for(int i = elementStart + 1; i < elementStop; i++)
	{
		VelCPU[i].x = ((float)rand()/(float)RAND_MAX)*2.0 - 1.0;;
		VelCPU[i].y = ((float)rand()/(float)RAND_MAX)*2.0 - 1.0;;
		VelCPU[i].z = ((float)rand()/(float)RAND_MAX)*2.0 - 1.0;;
		mag = sqrt(VelCPU[i].x*VelCPU[i].x + VelCPU[i].y*VelCPU[i].y + VelCPU[i].z*VelCPU[i].z);
		speed = ((float)rand()/(float)RAND_MAX)*speed;
		VelCPU[i].x *= speed/mag;
		VelCPU[i].y *= speed/mag;
		VelCPU[i].z *= speed/mag;
	
		VelCPU[i].w = elementPressure;
		
		ForceCPU[i].x = 0.0;
		ForceCPU[i].y = 0.0;
		ForceCPU[i].z = 0.0;
		
		ForceCPU[i].w = elementDiameter;
	}
	
	return(1);
}

float3 getCenterOfMass(int starNumber)
{
	double totalMass,cmx,cmy,cmz;
	float3 centerOfMass;
	int elementStart, elementStop;
	
	if(starNumber == 1)
	{
		elementStart = 0;
		elementStop = NumberElementsStar1;
	}
	if(starNumber == 2)
	{
		elementStart = NumberElementsStar1;
		elementStop = NumberElements; 
	}
	
	cmx = 0.0;
	cmy = 0.0;
	cmz = 0.0;
	totalMass = 0.0;
	
	// This is asuming the mass of each element is 1.
	for(int i = elementStart; i < elementStop; i++)
	{
    		cmx += PosCPU[i].x*PosCPU[i].w;
		cmy += PosCPU[i].y*PosCPU[i].w;
		cmz += PosCPU[i].z*PosCPU[i].w;
		totalMass += PosCPU[i].w;
	}
	
	centerOfMass.x = cmx/totalMass;
	centerOfMass.y = cmy/totalMass;
	centerOfMass.z = cmz/totalMass;
	return(centerOfMass);
}

float3 getAverageLinearVelocity(int starNumber)
{
	double totalMass, avx, avy, avz;
	float3 averagelinearVelocity;
	int elementStart, elementStop;
	
	if(starNumber == 1)
	{
		elementStart = 0;
		elementStop = NumberElementsStar1;
	}
	if(starNumber == 2)
	{
		elementStart = NumberElementsStar1;
		elementStop = NumberElements; 
	}
	
	avx = 0.0;
	avy = 0.0;
	avz = 0.0;
	totalMass = 0.0;
	
	// This is asuming the mass of each element is 1.
	for(int i = elementStart; i < elementStop; i++)
	{
    		avx += VelCPU[i].x*PosCPU[i].w;
		avy += VelCPU[i].y*PosCPU[i].w;
		avz += VelCPU[i].z*PosCPU[i].w;
		totalMass += PosCPU[i].w;
	}
	
	averagelinearVelocity.x = avx/totalMass;
	averagelinearVelocity.y = avy/totalMass;
	averagelinearVelocity.z = avz/totalMass;
	return(averagelinearVelocity);
}

void setCenterOfMassToZero(int starNumber)
{
	float3 centerOfMass;
	int elementStart, elementStop;
	
	if(starNumber == 1)
	{
		elementStart = 0;
		elementStop = NumberElementsStar1;
	}
	if(starNumber == 2)
	{
		elementStart = NumberElementsStar1;
		elementStop = NumberElements; 
	}
	
	centerOfMass = getCenterOfMass(starNumber);
	
	for(int i = elementStart; i < elementStop; i++)
	{
		PosCPU[i].x -= centerOfMass.x;
		PosCPU[i].y -= centerOfMass.y;
		PosCPU[i].z -= centerOfMass.z;
	}	
}

void setAverageVelocityToZero(int starNumber)
{
	float3 averagelinearVelocity;
	int elementStart, elementStop;
	
	if(starNumber == 1)
	{
		elementStart = 0;
		elementStop = NumberElementsStar1;
	}
	if(starNumber == 2)
	{
		elementStart = NumberElementsStar1;
		elementStop = NumberElements; 
	}
	
	averagelinearVelocity = getAverageLinearVelocity(starNumber);
	
	for(int i = elementStart; i < elementStop; i++)
	{
		VelCPU[i].x -= averagelinearVelocity.x;
		VelCPU[i].y -= averagelinearVelocity.y;
		VelCPU[i].z -= averagelinearVelocity.z;
	}	
}

void spinStar(int starNumber)
{
	double 	rx, ry, rz;  		//vector from center of mass to the position vector
	double	nx, ny, nz;		//Unit vector perpendicular to the plane of spin
	float3 	centerOfMass;
	float4  spinVector;
	double 	mag;
	int elementStart, elementStop;
	
	if(starNumber == 1)
	{
		elementStart = 0;
		elementStop = NumberElementsStar1;
		spinVector.x = InitialSpin1.x;
		spinVector.y = InitialSpin1.y;
		spinVector.z = InitialSpin1.z;
		spinVector.w = InitialSpin1.w;
	}
	if(starNumber == 2)
	{
		elementStart = NumberElementsStar1;
		elementStop = NumberElements; 
		spinVector.x = InitialSpin2.x;
		spinVector.y = InitialSpin2.y;
		spinVector.z = InitialSpin2.z;
		spinVector.w = InitialSpin2.w;
	}
	
	//Making sure the spin vector is a unit vector
	mag = sqrt(spinVector.x*spinVector.x + spinVector.y*spinVector.y + spinVector.z*spinVector.z);
	if(ASSUME_ZERO_DOUBLE < mag)
	{
		spinVector.x /= mag;
		spinVector.y /= mag;
		spinVector.z /= mag;
	}
	else 
	{
		printf("\nTSU Error: In spinStar. The spin direction vector is zero.\n");
		exit(0);
	}
	
	centerOfMass = getCenterOfMass(starNumber);
	for(int i = elementStart; i < elementStop; i++)
	{
		//Creating a vector from the center of mass to the point
		rx = PosCPU[i].x - centerOfMass.x;
		ry = PosCPU[i].y - centerOfMass.y;
		rz = PosCPU[i].z - centerOfMass.z;
		double magsquared = rx*rx + ry*ry + rz*rz;
		double spinDota = spinVector.x*rx + spinVector.y*ry + spinVector.z*rz;
		double perpendicularDistance = sqrt(magsquared - spinDota*spinDota);
		double perpendicularVelocity = spinVector.w*2.0*PI*perpendicularDistance;
		
		//finding unit vector perpendicular to both the position vector and the spin vector
		nx =  (spinVector.y*rz - spinVector.z*ry);
		ny = -(spinVector.x*rz - spinVector.z*rx);
		nz =  (spinVector.x*ry - spinVector.y*rx);
		mag = sqrt(nx*nx + ny*ny + nz*nz);
		if(mag != 0.0)
		{
			nx /= mag;
			ny /= mag;
			nz /= mag;
				
			//Spining the element
			VelCPU[i].x += perpendicularVelocity*nx;
			VelCPU[i].y += perpendicularVelocity*ny;
			VelCPU[i].z += perpendicularVelocity*nz;
		}
	}		
}

double getStarRadius(int starNumber)
{
	double max, radius, temp;
	double coreRadius;
	int elementStart, elementStop;
	int count;
	
	if(starNumber == 1)
	{
		elementStart = 0;
		elementStop = NumberElementsStar1;
		coreRadius = DiameterCore1/2.0;
	}
	if(starNumber == 2)
	{
		elementStart = NumberElementsStar1;
		elementStop = NumberElements;
		coreRadius = DiameterCore2/2.0;
	}
	
	if((elementStop - elementStart) == 1)
	{
		return(coreRadius);
	}
	else
	{
		radius = -1.0;
		for(int i = elementStart; i < elementStop; i++)
		{
			temp = sqrt(PosCPU[i].x*PosCPU[i].x + PosCPU[i].y*PosCPU[i].y + PosCPU[i].z*PosCPU[i].z);
			if(radius < temp) 
			{
				radius = temp;
			}
		}
		
		max = radius;
		
		// At present the radius is the distance to the farthest element. I am going to reduce this radius by 1 percent
		// each iteration until 10 percent of the elements in the star are outside the radius. 
		// Then average this with the farthest element.
		count = 0;
		while(count <= 0.1*elementStop)
		{
			radius = radius - radius*0.01;
			count = 0;
			for(int i = elementStart; i < elementStop; i++)
			{
				temp = sqrt(PosCPU[i].x*PosCPU[i].x + PosCPU[i].y*PosCPU[i].y + PosCPU[i].z*PosCPU[i].z);
				if(radius < temp) 
				{
					count++;
				}
			}
		}
		return((radius+max)/2.0);
	}
}

void drawPictureSeperate()
{	
	double seperation;
	double diameterSun;
	double drawUnit;
	
	diameterSun = DIAMETER_SUN/SystemLengthConverterToKilometers;
	drawUnit = 1.0/(diameterSun/ZoomFactor);
	
	seperation = 3.0*diameterSun;
	
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	glColor3d(Core1Color.x,Core1Color.y,Core1Color.z);
	glPushMatrix();
		glTranslatef(drawUnit*(PosCPU[0].x + seperation), drawUnit*PosCPU[0].y, drawUnit*PosCPU[0].z);
		glutSolidSphere(drawUnit*DiameterCore1/2.0,10,10);
	glPopMatrix();
	
	glPointSize(2.0);
	glColor3d(Envelope1Color.x,Envelope1Color.y,Envelope1Color.z);
	glBegin(GL_POINTS);
 		for(int i = 0 + 1; i < NumberElementsStar1; i++)
		{
			glVertex3f(drawUnit*(PosCPU[i].x + seperation), drawUnit*PosCPU[i].y, drawUnit*PosCPU[i].z);
		}
	glEnd();
	
	glColor3d(1.0,1.0,1.0);
	glPushMatrix();
		glTranslatef(drawUnit*seperation, 0.0, 0.0);
		glutWireSphere(drawUnit*DiameterStar1/2.0,10,10);
	glPopMatrix();
	
	glColor3d(Core2Color.x,Core2Color.y,Core2Color.z);
	glPushMatrix();
		glTranslatef(drawUnit*(PosCPU[NumberElementsStar1].x - seperation), drawUnit*PosCPU[NumberElementsStar1].y, drawUnit*PosCPU[NumberElementsStar1].z);
		glutSolidSphere(drawUnit*DiameterCore2/2.0,10,10);
	glPopMatrix();
	
	glPointSize(2.0);
	glColor3d(Envelope2Color.x,Envelope2Color.y,Envelope2Color.z);
	glBegin(GL_POINTS);
 		for(int i = NumberElementsStar1 + 1; i < NumberElements; i++)
		{
			glVertex3f(drawUnit*(PosCPU[i].x - seperation), drawUnit*PosCPU[i].y, drawUnit*PosCPU[i].z);
		}
	glEnd();
	
	glColor3d(1.0,1.0,1.0);
	glPushMatrix();
		glTranslatef(-drawUnit*seperation, 0.0, 0.0);
		glutWireSphere(drawUnit*DiameterStar2/2.0,10,10);
	glPopMatrix();
	
	glutSwapBuffers();
}

__global__ void getForcesSeperate(float4 *pos, float4 *vel, float4 *force, int numberElementsStar1, int NumberElements, float corePlasmaPushBackReduction, float plasmaPlasmaPushBackReduction, int gPUNumber, int gPUsUsed)
{
	int id, ids, i, j, k;
	float4 posMe, velMe, forceMe;
	float4 partialForce;
	double forceSumX, forceSumY, forceSumZ;
	
	__shared__ float4 shPos[BLOCKSIZE];
	__shared__ float4 shVel[BLOCKSIZE];
	__shared__ float4 shForce[BLOCKSIZE];

	//id = threadIdx.x + blockDim.x*blockIdx.x;
	id = threadIdx.x + blockDim.x*blockIdx.x + blockDim.x*gridDim.x*gPUNumber;
	if(NumberElements <= id)
	{
		printf("\n TSU error: id out of bounds in getForcesSeperate. \n");
	}
		
	forceSumX = 0.0;
	forceSumY = 0.0;
	forceSumZ = 0.0;
		
	posMe.x = pos[id].x;
	posMe.y = pos[id].y;
	posMe.z = pos[id].z;
	posMe.w = pos[id].w;
	
	velMe.x = vel[id].x;
	velMe.y = vel[id].y;
	velMe.z = vel[id].z;
	velMe.w = vel[id].w;
	
	forceMe.x = force[id].x;
	forceMe.y = force[id].y;
	forceMe.z = force[id].z;
	forceMe.w = force[id].w;
	
	
	for(k =0; k < gPUsUsed; k++)
	{
		for(j = 0; j < gridDim.x; j++)
		{
			shPos[threadIdx.x]   = pos  [threadIdx.x + blockDim.x*j + blockDim.x*gridDim.x*k];
			shVel[threadIdx.x]   = vel  [threadIdx.x + blockDim.x*j + blockDim.x*gridDim.x*k];
			shForce[threadIdx.x] = force[threadIdx.x + blockDim.x*j + blockDim.x*gridDim.x*k];
			__syncthreads();
		   
			#pragma unroll 32
			for(i = 0; i < blockDim.x; i++)	
			{
				ids = i + blockDim.x*j + blockDim.x*gridDim.x*k;
				if((id < numberElementsStar1 && ids < numberElementsStar1) || (numberElementsStar1 <= id && numberElementsStar1 <= ids))
				{
					if(id != ids)
					{
						if(id == 0 || id == numberElementsStar1)
						{
							partialForce = calculateCorePlasmaForce(0, posMe, shPos[i], velMe, shVel[i], forceMe, shForce[i], corePlasmaPushBackReduction);
						}
						else if(ids == 0 || ids == numberElementsStar1)
						{
							partialForce = calculateCorePlasmaForce(1, posMe, shPos[i], velMe, shVel[i], forceMe, shForce[i], corePlasmaPushBackReduction);
						}
						else
						{
							partialForce = calculatePlasmaPlasmaForce(posMe, shPos[i], velMe, shVel[i], plasmaPlasmaPushBackReduction);
						}
						forceSumX += partialForce.x;
						forceSumY += partialForce.y;
						forceSumZ += partialForce.z;
					}
				}
			}
			__syncthreads();
		}
	}
	
	force[id].x = (float)forceSumX;
	force[id].y = (float)forceSumY;
	force[id].z = (float)forceSumZ;
}

__global__ void moveBodiesDamped(float4 *pos, float4 *vel, float4 *force, float damp, float dt, int gPUNumber)
{  
    	int id = threadIdx.x + blockDim.x*blockIdx.x + blockDim.x*gridDim.x*gPUNumber;

	vel[id].x += ((force[id].x-damp*vel[id].x)/pos[id].w)*dt;
	vel[id].y += ((force[id].y-damp*vel[id].y)/pos[id].w)*dt;
	vel[id].z += ((force[id].z-damp*vel[id].z)/pos[id].w)*dt;

	pos[id].x += vel[id].x*dt;
	pos[id].y += vel[id].y*dt;
	pos[id].z += vel[id].z*dt;
}

void starNbody(float runTime, float damp, float dt, int gPUsUsed)
{ 
	float time = 0.0;
	float printTime = 0.0;
	int   tdraw = 0;
	int offSet = NumberElements/gPUsUsed;
	
	while(time < runTime)
	{	
		//Finding the forces.
		for(int i = 0; i < gPUsUsed; i++)
		{
			cudaSetDevice(i);
			errorCheck("cudaSetDevice");
			getForcesSeperate<<<GridConfig, BlockConfig>>>(PosGPU[i], VelGPU[i], ForceGPU[i], NumberElementsStar1, NumberElements,  CorePlasmaPushBackReduction, PlasmaPlasmaPushBackReduction, i, gPUsUsed);
			errorCheck("getForcesSeperate");
		}
		
		//Moving the elements.
		for(int i = 0; i < gPUsUsed; i++)
		{
			cudaSetDevice(i);
			errorCheck("cudaSetDevice");
			moveBodiesDamped<<<GridConfig, BlockConfig>>>(PosGPU[i], VelGPU[i], ForceGPU[i], damp, dt, i);
			errorCheck("moveBodiesDamped");
		}
		cudaDeviceSynchronize();
		errorCheck("cudaDeviceSynchronize");
		
		//Sharing memory		
		for(int i = 0; i < gPUsUsed; i++)
		{
			cudaSetDevice(i);
			errorCheck("cudaSetDevice");
			for(int j = 0; j < gPUsUsed; j++)
			{
				if(i != j)
				{
					cudaMemcpyAsync(&PosGPU[j][i*offSet], &PosGPU[i][i*offSet], (NumberElements/gPUsUsed)*sizeof(float4), cudaMemcpyDeviceToDevice);
					errorCheck("cudaMemcpy Pos A");
					cudaMemcpyAsync(&VelGPU[j][i*offSet], &VelGPU[i][i*offSet], (NumberElements/gPUsUsed)*sizeof(float4), cudaMemcpyDeviceToDevice);
					errorCheck("cudaMemcpy Vel");
				}
			}
		}
		cudaDeviceSynchronize();
		errorCheck("cudaDeviceSynchronize");
		time += dt;
		
		tdraw++;
		if(tdraw == DrawRate) 
		{
			//Because it is shared above it will only need to be copied from one GPU.
			cudaSetDevice(0);
			errorCheck("cudaSetDevice");
			cudaMemcpy(PosCPU, PosGPU[0], (NumberElements)*sizeof(float4), cudaMemcpyDeviceToHost);
			errorCheck("cudaMemcpy Pos draw");
			drawPictureSeperate();
			tdraw = 0;
		}
		
		printTime += dt;
		if(PrintRate <= printTime) 
		{
			printf("\n Time = %f days", time/(24.0*3600.0/SystemTimeConverterToSeconds));
			printTime = 0.0;
		}
		
	}
}

void recordStartPosVelForceOfCreatedStars()
{
	FILE *startPosVelForceFile;
	float time = 0.0;
	
	startPosVelForceFile = fopen("FilesFromBuild/StartPosVelForce", "wb");
	
	fwrite(&time, sizeof(float), 1, startPosVelForceFile);
	fwrite(PosCPU, sizeof(float4),   NumberElements, startPosVelForceFile);
	fwrite(VelCPU, sizeof(float4),   NumberElements, startPosVelForceFile);
	fwrite(ForceCPU, sizeof(float4), NumberElements, startPosVelForceFile);
	
	fclose(startPosVelForceFile);
}

void readStarsBackIn()
{  
	float time;
	
	FILE *startFile = fopen("FilesFromBuild/StartPosVelForce","rb");
	if(startFile == NULL)
	{
		printf("\n\n The StartPosVelForce file does not exist\n\n");
		exit(0);
	}
	fread(&time, sizeof(float), 1, startFile);
	fread(PosCPU, sizeof(float4), NumberElements, startFile);
	fread(VelCPU, sizeof(float4), NumberElements, startFile);
	fread(ForceCPU, sizeof(float4), NumberElements, startFile);
	fclose(startFile);
}

double getAveragePlasmaPressure(int star)
{
	int start, stop;
	double temp = 0.0;
	if(star == 1)
	{
		start = 1;
		stop = NumberElementsStar1;
	}
	else
	{
		start = NumberElementsStar1 + 1;
		stop = NumberElements;
	}
	for(int i = start; i < stop; i++)
	{
		temp += VelCPU[i].w;
	}
	return(temp/((double)stop - (double)start));
}

void recordStarStats()
{
	FILE *starStatsFile;
	double massStar1, radiusStar1, densityStar1;
	double massStar2, radiusStar2, densityStar2;
	double averagePlasmaPressure1, averagePlasmaPressure2;
	
	massStar1 = (NumberElementsStar1 + MassOfCore1)*SystemMassConverterToKilograms;
	radiusStar1 = getStarRadius(1);
	radiusStar1 *= SystemLengthConverterToKilometers;
	densityStar1 = massStar1/((4.0/3.0)*PI*radiusStar1*radiusStar1*radiusStar1);
	
	massStar2 = (NumberElementsStar2 + MassOfCore1)*SystemMassConverterToKilograms;
	radiusStar2 = getStarRadius(2);
	radiusStar2 *= SystemLengthConverterToKilometers;
	densityStar2 = massStar1/((4.0/3.0)*PI*radiusStar2*radiusStar2*radiusStar2);
	
	starStatsFile = fopen("FilesFromBuild/StarBuildStats", "wb");
		fprintf(starStatsFile, " The conversion parameters to take you to and from our units to kilograms, kilometers, seconds follow\n");
		fprintf(starStatsFile, " Mass in our units is the mass of an element. In other words the mass of an element is one.\n");
		fprintf(starStatsFile, " Length in our units is the diameter of an element. In other words the diameter of an element is one.\n");
		fprintf(starStatsFile, " Time in our units is set so that the universal gravitational constant is 1.");
		fprintf(starStatsFile, "\n ");
		fprintf(starStatsFile, "\n Our length unit is this many kilometers: %e", SystemLengthConverterToKilometers);
		fprintf(starStatsFile, "\n Our mass unit is this many kilograms: %e", SystemMassConverterToKilograms);
		fprintf(starStatsFile, "\n Our time unit is this many seconds: %e or days %e\n\n", SystemTimeConverterToSeconds, SystemTimeConverterToSeconds/(60*60*24));
		
		fprintf(starStatsFile, "\n Our time step is this many of our units %f", Dt);
		fprintf(starStatsFile, "\n Our time step is this many second: %e or hours: %e\n\n", Dt*SystemTimeConverterToSeconds, Dt*SystemTimeConverterToSeconds/(60.0*60.0));
		
		averagePlasmaPressure1 = getAveragePlasmaPressure(1);
		averagePlasmaPressure2 = getAveragePlasmaPressure(2);
		fprintf(starStatsFile, "\n Average PressurePlasma1 in our units is: %e", averagePlasmaPressure1);
		fprintf(starStatsFile, "\n Average PressurePlasma2 in our units is: %e", averagePlasmaPressure2);
		fprintf(starStatsFile, "\n Average PressurePlasma1 in our given units is: %e", averagePlasmaPressure1*(SystemMassConverterToKilograms/(SystemTimeConverterToSeconds*SystemTimeConverterToSeconds*SystemLengthConverterToKilometers)));
		fprintf(starStatsFile, "\n Average PressurePlasma2 in our given units is: %e", averagePlasmaPressure2*(SystemMassConverterToKilograms/(SystemTimeConverterToSeconds*SystemTimeConverterToSeconds*SystemLengthConverterToKilometers)));
		fprintf(starStatsFile, "\n ");
		
		fprintf(starStatsFile, "\n Total number of elements in star1: %d", NumberElementsStar1);
		fprintf(starStatsFile, "\n Total number of elements in star2: %d", NumberElementsStar2);
		fprintf(starStatsFile, "\n ");
		
		fprintf(starStatsFile, "\n Mass of Star1 = %e kilograms in Sun units = %e", massStar1, massStar1/MASS_SUN);
		fprintf(starStatsFile, "\n Diameter of Star1 = %e kilometers in Sun units = %e", 2.0*radiusStar1, 2.0*radiusStar1/DIAMETER_SUN);
		fprintf(starStatsFile, "\n Density of star1 = %e kilograms/(cubic kilometers)", densityStar1);
		fprintf(starStatsFile, "\n Mass of Star2 = %e kilograms in Sun units = %e", massStar2, massStar2/MASS_SUN);
		fprintf(starStatsFile, "\n Diameter of Star2 = %e kilometers in Sun units = %e", 2.0*radiusStar2, 2.0*radiusStar2/DIAMETER_SUN);
		fprintf(starStatsFile, "\n Density of star2 = %e kilograms/(cubic kilometers)", densityStar2);
	fclose(starStatsFile);
}

static void signalHandler(int signum)
{

	int command;
   
	cout << "\n\n******************************************************" << endl;
	cout << "Enter:666 to kill the run." << endl;
	cout << "******************************************************\n\nCommand: ";
    
	cin >> command;
    
	if(command == 666)
	{
		cout << "\n\n******************************************************" << endl;
		cout << "Are you sure you want to terminate the run?" << endl;
		cout << "Enter:666 again if you are sure. Enter anything else to continue the run." << endl;
		cout << "******************************************************\n\nCommand: ";
		cin >> command;
		
		if(command == 666)
		{
			exit(0);
		}
	}
	else
	{
		cout <<"\n\n Invalid Command\n" << endl;
	}

	exit(0);
}

void control()
{	
	struct sigaction sa;
	float damp, time;
	int gPUsUsed;
	clock_t startTimer, endTimer;
	
	//Starting the timer.
	startTimer = clock();
	
	// Handling input from the screen.
	sa.sa_handler = signalHandler;
	sigemptyset(&sa.sa_mask);
	sa.sa_flags = SA_RESTART; // Restart functions if interrupted by handler
	if (sigaction(SIGINT, &sa, NULL) == -1)
	{
		printf("\nTSU Error: sigaction error\n");
	}
	
	// Creating folder to hold the newly created stars and moving into that folder. It also makes a copy of the BiuldSetup file in this folder.
	printf("\n Creating folders for new stars. \n");
	createFolderForNewStars();
	
	// Reading in the build parameters to a file.
	printf("\n Reading build parameters. \n");
	readBuildParameters();
	
	// Creating and saving the run parameters to a file.
	printf("\n Saving run parameters. \n");
	generateAndSaveRunParameters();
	
	// Allocating memory for CPU and GPU.
	printf("\n Allocating memory. \n");
	allocateCPUMemory();
	
	// Generating raw stars
	printf("\n Generating raw star1. \n");
	createRawStar(1);	
	printf("\n Generating raw star2. \n");
	createRawStar(2);	
	 
	drawPictureSeperate();
	//while(1);
	
	// Seting up the GPU.
	printf("\n Setting up GPUs \n");
	gPUsUsed = deviceSetup();
	
	// The raw stars are in unnatural positions and have unnatural velocities. 
	// The stars need to be run with a damping factor turned on 
	// to let the stars move into naturl configurations. The damp will start high and be reduced to zero
	time = RawStarDampTime/RawStarDampLevels;  
	printf("\n Damping raw stars for = %f hours, Dt = %f hours\n", time*SystemTimeConverterToSeconds/3600.0, Dt*SystemTimeConverterToSeconds/3600.0);
	copyStarsUpToGPU(gPUsUsed);
	for(int i = 0; i < RawStarDampLevels; i++)
	{
		damp = RawStarDampAmount - float(i)*RawStarDampAmount/((float)RawStarDampLevels);
		printf("\n Damping raw stars interation %d out of %d", i+1, RawStarDampLevels);
		starNbody(time, damp, Dt, gPUsUsed);
	}
	
	// Letting any residue from the damping settle out.
	time = RawStarRestTime;  
	printf("\n\n Resting raw damped stars for %f hours", time*SystemTimeConverterToSeconds/3600.0);
	starNbody(time, 0.0, Dt, gPUsUsed);

	
	// Centering the stars and taking out any drift.
	copyStarsDownFromGPU();
	setCenterOfMassToZero(1);
	setCenterOfMassToZero(2);
	setAverageVelocityToZero(1);
	setAverageVelocityToZero(2);
	
	// Now we need to set the push backs so that the radii of the stars is correct.
	printf("\n\n Running radius adjustment.");
	float corrector;
	float currentDiameterStar1 = 2.0*getStarRadius(1);
	float currentDiameterStar2 = 2.0*getStarRadius(2);
	printf("\n\n percent out1 = %f percent out2 = %f", (currentDiameterStar1 - DiameterStar1)/DiameterStar1, (currentDiameterStar2 - DiameterStar2)/DiameterStar2);
	printf("\n plasma pushback1 = %f or %e",VelCPU[2].w, VelCPU[2].w*(SystemMassConverterToKilograms/(SystemTimeConverterToSeconds*SystemTimeConverterToSeconds*SystemLengthConverterToKilometers)));
	printf("\n plasma pushback2 = %f or %e",VelCPU[NumberElementsStar1 +2].w, VelCPU[NumberElementsStar1 +2].w*(SystemMassConverterToKilograms/(SystemTimeConverterToSeconds*SystemTimeConverterToSeconds*SystemLengthConverterToKilometers)));
	
	while((DiameterTolerance < abs(currentDiameterStar1 - DiameterStar1)/DiameterStar1) || (DiameterTolerance < abs(currentDiameterStar2 - DiameterStar2)/DiameterStar2))
	{
		if(DiameterStar1 < currentDiameterStar1)
		{
			corrector = DiameterAdjustmentSoftener*(currentDiameterStar1 - DiameterStar1)/currentDiameterStar1;
		}
		else
		{
			corrector = 10.0*DiameterAdjustmentSoftener*(currentDiameterStar1 - DiameterStar1)/DiameterStar1;
		}
		for(int i = 0; i < NumberElementsStar1; i++)
		{
			VelCPU[i].w = VelCPU[i].w*(1.0 - corrector);
		}
		
		//damp = DiameterAdjustmentDamp*abs(1.0 - corrector);
		damp = DiameterAdjustmentDamp*DiameterStar1/currentDiameterStar1;
		
		
		if(DiameterStar2 < currentDiameterStar2)
		{
			corrector = DiameterAdjustmentSoftener*(currentDiameterStar2 - DiameterStar2)/currentDiameterStar2;
		}
		else
		{
			corrector = 10.0*DiameterAdjustmentSoftener*(currentDiameterStar2 - DiameterStar2)/DiameterStar2;
		}
		for(int i = NumberElementsStar1; i < NumberElements; i++)
		{
			VelCPU[i].w = VelCPU[i].w*(1.0 - corrector);
		}
		
		if(damp < DiameterAdjustmentDamp*DiameterStar2/currentDiameterStar2)
		{
			//damp = DiameterAdjustmentDamp*abs(1.0 - corrector);
			damp = DiameterAdjustmentDamp*DiameterStar2/currentDiameterStar2;
		}
		
		copyStarsUpToGPU(gPUsUsed);
		time = DiameterAdjustmentTime;
		starNbody(time, damp, Dt, gPUsUsed);
		
		copyStarsDownFromGPU();
		currentDiameterStar1 = 2.0*getStarRadius(1);
		currentDiameterStar2 = 2.0*getStarRadius(2);
		
		printf("\n\n percent out1 = %f percent out2 = %f", (currentDiameterStar1 - DiameterStar1)/DiameterStar1, (currentDiameterStar2 - DiameterStar2)/DiameterStar2);
		printf("\n plasma pushback1 = %f or %e",VelCPU[2].w, VelCPU[2].w*(SystemMassConverterToKilograms/(SystemTimeConverterToSeconds*SystemTimeConverterToSeconds*SystemLengthConverterToKilometers)));
		printf("\n plasma pushback2 = %f or %e",VelCPU[NumberElementsStar1 +2].w, VelCPU[NumberElementsStar1 +2].w*(SystemMassConverterToKilograms/(SystemTimeConverterToSeconds*SystemTimeConverterToSeconds*SystemLengthConverterToKilometers)));
	}
	
	// Letting any residue from the radius adjustment settle out.
	time = DiameterAdjustmentRestTime;
	printf("\n\n Resting diameter adjustment for %f hours", time*SystemTimeConverterToSeconds/3600.0);
	damp = 0.0;
	starNbody(time, damp, Dt, gPUsUsed);
	
	// Spinning stars
	copyStarsDownFromGPU();
	setCenterOfMassToZero(1);
	setCenterOfMassToZero(2);
	setAverageVelocityToZero(1);
	setAverageVelocityToZero(2);
	printf("\n\n Spinning star1. \n");
	spinStar(1);	
	printf("\n Spinning star2. \n");
	spinStar(2);
	
	// Letting any residue from the spinning settle out.
	copyStarsUpToGPU(gPUsUsed);
	time = SpinRestTime;
	damp = 0.0;
	printf("\n Running spin rest.");
	starNbody(time, 0.0, Dt, gPUsUsed);
	
	//Centering and removing any drift from stars.
	copyStarsDownFromGPU();
	setCenterOfMassToZero(1);
	setCenterOfMassToZero(2);
	setAverageVelocityToZero(1);
	setAverageVelocityToZero(2);
	
	// Saving the stars positions and velocities to a file.
	printf("\n\n Saving final positions, velocities, and forces \n");	
	// Removing the fill that was used to hold temperaraly hold the stars before spinning.
	system("rm FilesFromBuild/StartPosVelForce");
	recordStartPosVelForceOfCreatedStars(); 
	
	printf("\n Recording stats \n");
	recordStarStats();	
	
	// Freeing memory. 	
	printf("\n Cleaning up \n");
	cleanUp(gPUsUsed);
	
	// Stopping timer and printing out run time.
	endTimer = clock();
	int seconds = (endTimer - startTimer)/CLOCKS_PER_SEC;
	int hours = seconds/3600;
	int minutes = (seconds - hours*3600)/60;
	seconds = seconds - hours*3600 - minutes*60;
   	printf("\n Total time taken for this run: %d hours %d minutes %d seconds\n", hours, minutes, seconds);

	printf("\n The run has finished successfully \n\n");
	exit(0);
}

int main(int argc, char** argv)
{ 
	glutInit(&argc,argv);
	glutInitDisplayMode(GLUT_DOUBLE | GLUT_DEPTH | GLUT_RGB);
	glutInitWindowSize(XWindowSize,YWindowSize);
	glutInitWindowPosition(0,0);
	glutCreateWindow("Creating Stars");
	
	glutReshapeFunc(reshape);
	
	init();
	
	glShadeModel(GL_SMOOTH);
	glClearColor(0.0, 0.0, 0.0, 0.0);
	
	glutDisplayFunc(Display);
	glutReshapeFunc(reshape);
	glutIdleFunc(control);
	glutMainLoop();
	return 0;
}






