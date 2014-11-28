// by Les Hall
// started Wed Oct 22 2014
// 


debug = true;
numFins = 3;
bodyLength = 114 / sin(acos(0.5));
thickness = 2;
motorLength = 70;
motorDiameter = 18;
motorPositionZ = -bodyLength/2*
	sin(acos((bodyLength/4+motorDiameter+2*thickness)/(bodyLength/2)));
$fn = 64;

echo(motorPositionZ);
echo(bodyLength/2*cos(motorPositionZ/(bodyLength/2))-bodyLength/2);


if (debug)
{
	difference()
	{
		rocket();
		
		translate([100, 100, 0])
		cube(200, center=true);
	}
}
else
{
	difference()
	{
		union()
		{
			translate([-bodyLength/4, 0, motorLength+thickness])
			rotate(180, [1, 0, 0])
			translate([0, 0, -motorPositionZ])
			rocket();
			
			translate([bodyLength/4, 0, 
				-motorPositionZ-motorLength-thickness])
			rocket();
		}
		
		translate([0, 0, -100])
		cube(200, center=true);
	}
}



module rocket()
{
	difference()
	{
		// outer shell of body
		body(bodyLength);
		
		// inner shell of body
		body(bodyLength-4*thickness);
		
		// hole in base
		translate([0, 0, motorPositionZ-bodyLength/4])
		cylinder(d=bodyLength/2, h=bodyLength/2, center=true);
	}
	
	// motor mount
	union()
	{
		translate([0, 0, motorPositionZ + motorLength/2])
		difference()
		{
			cylinder(d=motorDiameter+2*thickness, h=motorLength, center=true);
			cylinder(d=motorDiameter, h=motorLength, center=true);
		}
		
		translate([0, 0, motorPositionZ + motorLength + thickness/2])
		difference()
		{
			cylinder(d=motorDiameter+2*thickness, h=thickness, center=true);
			cylinder(d=motorDiameter-2*thickness, h=thickness, center=true);
		}
	}
	
	// fins
	for(t=[0:numFins-1])
	assign(theta=360*t/numFins)
	rotate(theta, [0, 0, 1])
	fin(bodyLength-thickness);
}




module fin(s=100)
{
	intersection()
	{
		difference()
		{
			translate([0, 0, -s*3/4])
			{
				difference()
				{
					// outer fin shape
					scale([1, 1, 3])
					sphere(d=s/2);
					
					// inner fin shape
					scale([1, 1, 2])
					sphere(d=s/2);
				}
			}
			
			// body gap
			body(s);
		}
		
		translate([100, 0, -s/4])
		cube([200, 2*thickness, s/2], center=true);
	}
}



module body(s=100)
{
	scale([s/2, s/2, s])
	rotate_extrude()
	difference()
	{
		translate([-0.25, 0, 0])
		circle(d=1, center=true);
	
		translate([-0.5, 0, 0])
		square(1, center=true);
	}
}	




