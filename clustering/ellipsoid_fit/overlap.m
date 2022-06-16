function doOverlap=overlap(Ellipsoid1,Ellipsoid2)

%Input
%Ellipsoid1 and Ellipsoid2 are (1*9) arrays. each cell represent: 
            %(1): radius of ellipsoids at direction 1
            %(2): radius of ellipsoids at direction 2
            %(3): radius of ellipsoids at direction 3
            %(4): x-cooridante of centroid
            %(5): y-coordinate of centroid
            %(6): z-coordinate of centroid
            %(7): Inclination angle 1
            %(8): Inclination angle 2
            %(9): Inclination angle 3
            
%output
%doOverlap: true if there is overlap, otherwise it is false

E1=E(Ellipsoid1(1),Ellipsoid1(2),Ellipsoid1(3),Ellipsoid1(4),Ellipsoid1(5),Ellipsoid1(6),Ellipsoid1(7),Ellipsoid1(8),Ellipsoid1(9));
E2=E(Ellipsoid2(1),Ellipsoid2(2),Ellipsoid2(3),Ellipsoid2(4),Ellipsoid2(5),Ellipsoid2(6),Ellipsoid2(7),Ellipsoid2(8),Ellipsoid2(9));

doOverlap=true;
e = eig(-E2,E1);
e=e(e==real(e)); %Remove imaginary roots
k=find(e>0);
if length(k)==2
if k(1)~=k(2) 
doOverlap=false;     
end
end

end