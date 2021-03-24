/*
nvcc Viewer.cu -o Viewer.exe -lglut -lGL -lGLU -lm
nvcc Viewer.cu -o Viewer.exe -lglut -lGL -lGLU -lm --use_fast_math
*/

#include "../CommonCompileFiles/binaryStarCommonIncludes.h"
#include "../CommonCompileFiles/binaryStarCommonDefines.h"
#include "../CommonCompileFiles/binaryStarCommonGlobals.h"
#include "../CommonCompileFiles/binaryStarCommonFunctions.h"
#include "../CommonCompileFiles/binaryStarCommonRunGlobals.h"
#include "../CommonCompileFiles/binaryStarCommonRunFunctions.h"

//Time to add on to the run. Readin from the comand line.
float ContinueRunTime;

void openAndReadFiles()
{
	ifstream data;
	string name;
	
	//Opening the positions and velosity file to dump stuff to make movies out of. Need to move to the end of the file.
	PosAndVelFile = fopen("PosAndVel", "rb+");
	if(PosAndVelFile == NULL)
	{
		printf("\n\n The PosAndVel file does not exist\n\n");
		exit(0);
	}
	//fseek(PosAndVelFile,0,SEEK_END);
	
	//Reading in the run parameters
	data.open("RunParameters");
	if(data.is_open() == 1)
	{
		getline(data,name,'=');
		data >> SystemLengthConverterToKilometers;
		
		getline(data,name,'=');
		data >> SystemMassConverterToKilograms;
		
		getline(data,name,'=');
		data >> SystemTimeConverterToSeconds;
		
		getline(data,name,'=');
		data >> NumberElementsStar1;
		
		getline(data,name,'=');
		data >> NumberElementsStar2;
		
		getline(data,name,'=');
		data >> CoreCorePushBackReduction;
		
		getline(data,name,'=');
		data >> CorePlasmaPushBackReduction;
		
		getline(data,name,'=');
		data >> PlasmaPlasmaPushBackReduction;
		
		getline(data,name,'=');
		data >> Dt;
		
		getline(data,name,'=');
		data >> ZoomFactor;
		
		getline(data,name,'=');
		data >> PrintRate;
	}
	else
	{
		printf("\nTSU Error could not open RunParameters file\n");
		exit(0);
	}
	data.close();
	NumberElements = NumberElementsStar1 + NumberElementsStar2;
}

void drawPictureViewer()
{	
	double diameterSun;
	double drawUnit;
	
	diameterSun = DIAMETER_SUN/SystemLengthConverterToKilometers;
	drawUnit = 1.0/(diameterSun/ZoomFactor);
	
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	//Drawing the cores spheres
	glPushMatrix();
		glTranslatef(drawUnit*(PosCPU[0].x - CenterOfView.x), drawUnit*(PosCPU[0].y - CenterOfView.y), drawUnit*(PosCPU[0].z - CenterOfView.z));
		glColor3d(1.0,0.0,0.0);
		glutSolidSphere(drawUnit*diameterSun*0.2/2.0,20,20);  // force.w holds the diameter of an element
	glPopMatrix();
	
	glPushMatrix();
		glTranslatef(drawUnit*(PosCPU[NumberElementsStar1].x - CenterOfView.x), drawUnit*(PosCPU[NumberElementsStar1].y - CenterOfView.y), drawUnit*(PosCPU[NumberElementsStar1].z - CenterOfView.z));
		glColor3d(0.0,0.0,1.0);
		glutSolidSphere(drawUnit*diameterSun*0.2/2.0,20,20);
	glPopMatrix();
	
	//Drawing all the elements as points
	glBegin(GL_POINTS);
		glPointSize(5.0);
		glColor3d(1.0,1.0,0.0);
 		for(int i = 0; i < NumberElementsStar1; i++)
		{
			glVertex3f(drawUnit*(PosCPU[i].x - CenterOfView.x), drawUnit*(PosCPU[i].y - CenterOfView.y), drawUnit*(PosCPU[i].z - CenterOfView.z));
		}
		glColor3d(1.0,0.6,0.0);
		for(int i = NumberElementsStar1; i < NumberElements; i++)
		{
			glVertex3f(drawUnit*(PosCPU[i].x - CenterOfView.x), drawUnit*(PosCPU[i].y - CenterOfView.y), drawUnit*(PosCPU[i].z - CenterOfView.z));
		}
	glEnd();
	
	glutSwapBuffers();
}

void control()
{	
	float time;
	
	// Reading in the build parameters.
	printf("\n Reading and setting the run parameters.\n");
	openAndReadFiles();
	
	// Allocating memory for CPU and GPU.
	printf("\n Allocating memory on the GPU and CPU and opening positions and velocities file.\n");
	allocateCPUMemory();
	
	float temp = -10.0;
	int stop = 0;
	while(stop != 1)
	{
		fread(&time, sizeof(float), 1, PosAndVelFile);
		if(temp - time == 0.0) 
		{
			stop = 1;
		}
		temp = time;
		fread(PosCPU, sizeof(float4), NumberElements, PosAndVelFile);
		fread(VelCPU, sizeof(float4), NumberElements, PosAndVelFile);
		printf("\n time =%f", time);
		drawPictureViewer();
	}
	printf("\n The run has finished successfully \n\n");
	//while(1);
	
	// Freeing memory. 	
	printf("\n Cleaning up the run.\n");
	//cleanUp(gPUsUsed);
	fclose(PosAndVelFile);

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

