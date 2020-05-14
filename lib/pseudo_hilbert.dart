import 'package:flutter/material.dart';

// implementation/modification of algorithm found here: http://lutanho.net/pic2html/draw_sfc.html

/*
TODO:
write split()
  assuming that the start corner is top left, splits into several smaller boxes
*/

enum Corner{
  topLeft,
  topRight,
  bottomRight,
  bottomLeft
}

bool isEven(int n){ //TODO: actually use this function
  return n % 2 == 0;
}

List<int> generatePath(int width, int height){
  RecursiveBox box = RecursiveBox.initial(width, height);
  return box.recursePath();
}

class RecursiveBox{
  List values;
  int width;
  int height;
  Corner startCorner;
  Corner endCorner;

  //constructor for box representing the entire motor matrix
  RecursiveBox.initial(this.width, this.height){
    //generates array of arrays of integers representing matrix of motors,
    //with the first sub-array being [1, 2, 3... n], the second being [n+1, n+2... 2*n], and so on, where n is the width of the matrix
    values = List.generate(height, (int heightIndex) => List.generate(width, (int widthIndex) => (heightIndex * width + widthIndex)));
    //decide start and end points for whole curve
    startCorner = Corner.topLeft;
    if(width > height){
      if(!isEven(width) && isEven(height)){
        endCorner = Corner.bottomRight;
      }
      else{
        endCorner = Corner.topRight;
      }
    }
    else{
      if(isEven(width) && !isEven(height)){
        endCorner = Corner.bottomRight;
      }
      else{
        endCorner = Corner.bottomLeft;
      }
    }
  }

  RecursiveBox.topLeftCorner(RecursiveBox badBox){
    startCorner = Corner.topLeft;
    int rotateNum = (4 - badBox.startCorner.index) % 4;
    int endCornerIndex = (badBox.endCorner.index + rotateNum) % 4;
    endCorner = Corner.values[endCornerIndex];
    List tempValues = badBox.values;
    for(int i = 0; i < rotateNum; i++){
      tempValues = rotateClockwise(tempValues);
    }
    values = tempValues;
    this.height = values.length;
    this.width = values[0].length;
  }

  List<List<int>> rotateClockwise(List<List<int>> input){
    int n = input.length;
    int m = input[0].length;
    List<List<int>> output = List.generate(m, (int index) => List(n));

    for (int i=0; i<n; i++)
	    for (int j=0;j<m; j++)
		    output [j][n-1-i] = input[i][j];
    return output;
  }

  RecursiveBox(this.values, this.startCorner, this.endCorner){
    height = values.length;
    width = values[0].length;
  }

  List<int> recursePath(){
    //if dimensions 2x3 or less, return path between all of them
    if((height <= 3 && width <= 3) && (height <= 2 || width <= 2)){
      return _generate();
    }
    else{
      List<RecursiveBox> subBoxes = _split();
      List<int> path = List<int>();
      //generates paths for each sub_box and puts them in order
      subBoxes.forEach((box) => path.addAll(box.recursePath()));
      return path;
    }
  }
  
  //if path is small, return hard-coded answer 
  List<int> _generate(){
    assert (startCorner == Corner.topLeft);
    List<int> path = List();
    if(height == 1){
      path.addAll(values[0]);
    }
    else if(width == 1){
      for(List<int> row in values){
        path.add(row[0]);
      }
    }
    else if(height == 2 && width == 2){
      assert (endCorner != Corner.bottomRight);
      if(endCorner == Corner.topRight){
        path.add(values[0][0]);
        path.add(values[1][0]);
        path.add(values[1][1]);
        path.add(values[0][1]);
      }
      else{
        path.add(values[0][0]);
        path.add(values[0][1]);
        path.add(values[1][1]);
        path.add(values[1][0]);
      }
    }
    else if(height == 3){
      assert (endCorner != Corner.bottomLeft);
      if(endCorner == Corner.topRight){
        path.add(values[0][0]);
        path.add(values[1][0]);
        path.add(values[2][0]);
        path.add(values[2][1]);
        path.add(values[1][1]);
        path.add(values[0][1]);
      }
      else{
        path.add(values[0][0]);
        path.add(values[0][1]);
        path.add(values[1][1]);
        path.add(values[1][0]);
        path.add(values[2][0]);
        path.add(values[2][1]);
      }
    }
    else if(height == 3){
      assert (endCorner != Corner.topRight);
      if(endCorner == Corner.bottomLeft){
        path.add(values[0][0]);
        path.add(values[0][1]);
        path.add(values[0][2]);
        path.add(values[1][2]);
        path.add(values[1][1]);
        path.add(values[1][0]);
      }
      else{
        path.add(values[0][0]);
        path.add(values[1][0]);
        path.add(values[1][1]);
        path.add(values[0][1]);
        path.add(values[0][2]);
        path.add(values[1][2]);
      }
    }
    return path;
  }

  //splits up box into smaller boxes, returns them in ordered list
  List<RecursiveBox> _split(){
    assert(startCorner == Corner.topLeft);
    List<RecursiveBox> subBoxes = new List<RecursiveBox>();
    bool splitInto2 = false;
    //split into 2 boxes side to side
    if(!splitInto2 && width > 1.5 * height){
      int widthFirstHalf = (width/2.0).round();
      List<List<int>> box1Values = List.generate(height, (int heightIndex) => List.generate(widthFirstHalf, (int widthIndex) => (values[heightIndex][widthIndex])));
      List<List<int>> box2Values = List.generate(height, (int heightIndex) => List.generate(width - widthFirstHalf, (int widthIndex) => (values[heightIndex][widthFirstHalf + widthIndex])));
      if(height % 2 == 0){ //if height is even
        if(width % 2 == 0){ //if width is even
          if(endCorner == Corner.topRight){ //if going the correct direction for 1x2, split, else break out of this if statement and go split into 2x2 or 3x3
            if(width % 4 == 0){ //make 2 parts even-even from even width
              subBoxes.add(RecursiveBox(box1Values, Corner.topLeft, Corner.topRight));
              subBoxes.add(RecursiveBox(box2Values, Corner.topLeft, Corner.topRight));
            }
            else{ //make 2 parts odd-odd from even width
              subBoxes.add(RecursiveBox(box1Values, Corner.topLeft, Corner.bottomRight));
              subBoxes.add(RecursiveBox(box2Values, Corner.bottomLeft, Corner.topRight));
            }
            splitInto2 = true;
          }
        }
        else{ //if width is odd
          if(endCorner == Corner.topLeft){
            if(widthFirstHalf % 2 == 0){ //split even-odd
              subBoxes.add(RecursiveBox(box1Values, Corner.topLeft, Corner.topRight));
              subBoxes.add(RecursiveBox(box2Values, Corner.topLeft, Corner.bottomRight));
            }
            else{ //split odd-even
              subBoxes.add(RecursiveBox(box1Values, Corner.topLeft, Corner.bottomRight));
              subBoxes.add(RecursiveBox(box2Values, Corner.bottomLeft, Corner.bottomRight));
            }
            splitInto2 = true;
          }
        }
      }
      else{ //if height is odd
        if(endCorner == Corner.topRight){
          subBoxes.add(RecursiveBox(box1Values, Corner.topLeft, Corner.topRight));
          subBoxes.add(RecursiveBox(box2Values, Corner.topLeft, Corner.topRight));
          splitInto2 = true;
        }
        else if(endCorner == Corner.bottomRight){
          subBoxes.add(RecursiveBox(box1Values, Corner.topLeft, Corner.topRight));
          subBoxes.add(RecursiveBox(box2Values, Corner.topLeft, Corner.bottomRight));
          splitInto2 = true;
        }
      }
    }
    //split into 2 boxes above and below each other
    if(!splitInto2 && height > 1.5 * width){
      int heightFirstHalf = (height/2.0).round();
      List<List<int>> box1Values = List.generate(heightFirstHalf, (int heightIndex) => List.generate(width, (int widthIndex) => (values[heightIndex][widthIndex])));
      List<List<int>> box2Values = List.generate(height - heightFirstHalf, (int heightIndex) => List.generate(width, (int widthIndex) => (values[heightFirstHalf + heightIndex][widthIndex])));
      if(width % 2 == 0){ //if width is even
        if(height % 2 == 0){ //if height is even
          if(endCorner == Corner.bottomLeft){ //if going the correct direction for 1x2, split, else break out of this if statement and go split into 2x2 or 3x3
            if(height % 4 == 0){ //make 2 parts even-even from even height
              subBoxes.add(RecursiveBox(box1Values, Corner.topLeft, Corner.bottomLeft));
              subBoxes.add(RecursiveBox(box2Values, Corner.topLeft, Corner.bottomLeft));
            }
            else{ //make 2 parts odd-odd from even width
              subBoxes.add(RecursiveBox(box1Values, Corner.topLeft, Corner.bottomRight));
              subBoxes.add(RecursiveBox(box2Values, Corner.topRight, Corner.bottomLeft));
            }
            splitInto2 = true;
          }
        }
        else{ //if height is odd
          if(endCorner == Corner.bottomRight){
            if(heightFirstHalf % 2 == 0){ //split even-odd
              subBoxes.add(RecursiveBox(box1Values, Corner.topLeft, Corner.bottomLeft));
              subBoxes.add(RecursiveBox(box2Values, Corner.topLeft, Corner.bottomRight));
            }
            else{ //split odd-even
              subBoxes.add(RecursiveBox(box1Values, Corner.topLeft, Corner.bottomRight));
              subBoxes.add(RecursiveBox(box2Values, Corner.topRight, Corner.bottomRight));
            }
            splitInto2 = true;
          }
        }
      }
      else{ //if width is odd
        if(endCorner == Corner.bottomLeft){
          subBoxes.add(RecursiveBox(box1Values, Corner.topLeft, Corner.bottomLeft));
          subBoxes.add(RecursiveBox(box2Values, Corner.topLeft, Corner.bottomLeft));
          splitInto2 = true;
        }
        else if(endCorner == Corner.bottomRight){
          subBoxes.add(RecursiveBox(box1Values, Corner.topLeft, Corner.bottomLeft));
          subBoxes.add(RecursiveBox(box2Values, Corner.topLeft, Corner.bottomRight));
          splitInto2 = true;
        }
      }
    }
    if(!splitInto2){ //if couldnt split 1x2 or 2x1, whether b/c wrong side length ratio or wrong direction for side parities
      //split into 2x2 boxes if path doing a u turn
      if(endCorner == Corner.topRight || endCorner == Corner.bottomLeft){
        int widthFirstHalf = (width/2.0).round();
        int heightFirstHalf = (height/2.0).round();
        List<List<int>> box1Values;
        List<List<int>> box2Values;
        List<List<int>> box3Values;
        List<List<int>> box4Values;
        if(height % 2 == 0 && width % 2 == 0){ //even-even
          if((widthFirstHalf + heightFirstHalf) % 2 == 0){ //ee-ee or oo-oo
            box1Values = List.generate(heightFirstHalf, (int heightIndex) => List.generate(widthFirstHalf, (int widthIndex) => (values[heightIndex][widthIndex])));
            box2Values = List.generate(heightFirstHalf, (int heightIndex) => List.generate(width - widthFirstHalf, (int widthIndex) => (values[heightIndex][widthFirstHalf + widthIndex])));
            box3Values = List.generate(height - heightFirstHalf, (int heightIndex) => List.generate(widthFirstHalf, (int widthIndex) => (values[heightFirstHalf + heightIndex][widthIndex])));
            box4Values = List.generate(height - heightFirstHalf, (int heightIndex) => List.generate(width - widthFirstHalf, (int widthIndex) => (values[heightFirstHalf + heightIndex][widthFirstHalf + widthIndex])));
            if(endCorner == Corner.topRight){
              subBoxes.add(RecursiveBox(box1Values, Corner.topLeft, Corner.bottomLeft));
              subBoxes.add(RecursiveBox(box3Values, Corner.topLeft, Corner.topRight));
              subBoxes.add(RecursiveBox(box4Values, Corner.topLeft, Corner.topRight));
              subBoxes.add(RecursiveBox(box2Values, Corner.bottomRight, Corner.topRight));
            }
            else{ //if endCorner == Corner.bottomLeft
              subBoxes.add(RecursiveBox(box1Values, Corner.topLeft, Corner.topRight));
              subBoxes.add(RecursiveBox(box2Values, Corner.topLeft, Corner.bottomLeft));
              subBoxes.add(RecursiveBox(box4Values, Corner.topLeft, Corner.bottomLeft));
              subBoxes.add(RecursiveBox(box3Values, Corner.bottomRight, Corner.bottomLeft));
            }
          }
          else{ //ee-oo or oo-ee
            if(widthFirstHalf % 2 == 0){ //ee-oo
              if(endCorner == Corner.topRight){
                box1Values = List.generate(heightFirstHalf, (int heightIndex) => List.generate(widthFirstHalf, (int widthIndex) => (values[heightIndex][widthIndex])));
                box2Values = List.generate(heightFirstHalf, (int heightIndex) => List.generate(width - widthFirstHalf, (int widthIndex) => (values[heightIndex][widthFirstHalf + widthIndex])));
                box3Values = List.generate(height - heightFirstHalf, (int heightIndex) => List.generate(widthFirstHalf, (int widthIndex) => (values[heightFirstHalf + heightIndex][widthIndex])));
                box4Values = List.generate(height - heightFirstHalf, (int heightIndex) => List.generate(width - widthFirstHalf, (int widthIndex) => (values[heightFirstHalf + heightIndex][widthFirstHalf + widthIndex])));
                subBoxes.add(RecursiveBox(box1Values, Corner.topLeft, Corner.bottomLeft));
                subBoxes.add(RecursiveBox(box3Values, Corner.topLeft, Corner.bottomRight));
                subBoxes.add(RecursiveBox(box4Values, Corner.bottomLeft, Corner.topRight));
                subBoxes.add(RecursiveBox(box2Values, Corner.bottomRight, Corner.topRight));
              }
              else{ //if endCorner == Corner.bottomLeft, ee-oo not possible, so becomes (e-1)(e+1)-oo, or in other words oo-oo
                widthFirstHalf--;
                box1Values = List.generate(heightFirstHalf, (int heightIndex) => List.generate(widthFirstHalf, (int widthIndex) => (values[heightIndex][widthIndex])));
                box2Values = List.generate(heightFirstHalf, (int heightIndex) => List.generate(width - widthFirstHalf, (int widthIndex) => (values[heightIndex][widthFirstHalf + widthIndex])));
                box3Values = List.generate(height - heightFirstHalf, (int heightIndex) => List.generate(widthFirstHalf, (int widthIndex) => (values[heightFirstHalf + heightIndex][widthIndex])));
                box4Values = List.generate(height - heightFirstHalf, (int heightIndex) => List.generate(width - widthFirstHalf, (int widthIndex) => (values[heightFirstHalf + heightIndex][widthFirstHalf + widthIndex])));
                subBoxes.add(RecursiveBox(box1Values, Corner.topLeft, Corner.topRight));
                subBoxes.add(RecursiveBox(box2Values, Corner.topLeft, Corner.bottomRight));
                subBoxes.add(RecursiveBox(box4Values, Corner.topRight, Corner.bottomLeft));
                subBoxes.add(RecursiveBox(box3Values, Corner.bottomRight, Corner.bottomLeft));
              }
            }
            else{ //oo-ee
              if(endCorner == Corner.bottomLeft){
                box1Values = List.generate(heightFirstHalf, (int heightIndex) => List.generate(widthFirstHalf, (int widthIndex) => (values[heightIndex][widthIndex])));
                box2Values = List.generate(heightFirstHalf, (int heightIndex) => List.generate(width - widthFirstHalf, (int widthIndex) => (values[heightIndex][widthFirstHalf + widthIndex])));
                box3Values = List.generate(height - heightFirstHalf, (int heightIndex) => List.generate(widthFirstHalf, (int widthIndex) => (values[heightFirstHalf + heightIndex][widthIndex])));
                box4Values = List.generate(height - heightFirstHalf, (int heightIndex) => List.generate(width - widthFirstHalf, (int widthIndex) => (values[heightFirstHalf + heightIndex][widthFirstHalf + widthIndex])));
                subBoxes.add(RecursiveBox(box1Values, Corner.topLeft, Corner.topRight));
                subBoxes.add(RecursiveBox(box2Values, Corner.topLeft, Corner.bottomRight));
                subBoxes.add(RecursiveBox(box4Values, Corner.topRight, Corner.bottomLeft));
                subBoxes.add(RecursiveBox(box3Values, Corner.bottomRight, Corner.bottomLeft));
              }
              else{ //if endCorner == Corner.topRight, oo-ee not possible, so becomes oo-(e-1)(e+1), or in other words oo-oo
                heightFirstHalf--;
                box1Values = List.generate(heightFirstHalf, (int heightIndex) => List.generate(widthFirstHalf, (int widthIndex) => (values[heightIndex][widthIndex])));
                box2Values = List.generate(heightFirstHalf, (int heightIndex) => List.generate(width - widthFirstHalf, (int widthIndex) => (values[heightIndex][widthFirstHalf + widthIndex])));
                box3Values = List.generate(height - heightFirstHalf, (int heightIndex) => List.generate(widthFirstHalf, (int widthIndex) => (values[heightFirstHalf + heightIndex][widthIndex])));
                box4Values = List.generate(height - heightFirstHalf, (int heightIndex) => List.generate(width - widthFirstHalf, (int widthIndex) => (values[heightFirstHalf + heightIndex][widthFirstHalf + widthIndex])));
                subBoxes.add(RecursiveBox(box1Values, Corner.topLeft, Corner.bottomLeft));
                subBoxes.add(RecursiveBox(box3Values, Corner.topLeft, Corner.bottomRight));
                subBoxes.add(RecursiveBox(box4Values, Corner.bottomLeft, Corner.topRight));
                subBoxes.add(RecursiveBox(box2Values, Corner.bottomRight, Corner.topRight));
              }
            }
          }
        }
        else{ //not even-even
          if(width % 2 != 0 && height % 2 != 0){ //odd-odd
            //make it eo-eo
            if(widthFirstHalf % 2 != 0){
              widthFirstHalf = width - widthFirstHalf;
            }
            if(heightFirstHalf % 2 != 0){
              heightFirstHalf = height - heightFirstHalf;
            }
            box1Values = List.generate(heightFirstHalf, (int heightIndex) => List.generate(widthFirstHalf, (int widthIndex) => (values[heightIndex][widthIndex])));
            box2Values = List.generate(heightFirstHalf, (int heightIndex) => List.generate(width - widthFirstHalf, (int widthIndex) => (values[heightIndex][widthFirstHalf + widthIndex])));
            box3Values = List.generate(height - heightFirstHalf, (int heightIndex) => List.generate(widthFirstHalf, (int widthIndex) => (values[heightFirstHalf + heightIndex][widthIndex])));
            box4Values = List.generate(height - heightFirstHalf, (int heightIndex) => List.generate(width - widthFirstHalf, (int widthIndex) => (values[heightFirstHalf + heightIndex][widthFirstHalf + widthIndex])));
            if(endCorner == Corner.topRight){
              subBoxes.add(RecursiveBox(box1Values, Corner.topLeft, Corner.bottomLeft));
              subBoxes.add(RecursiveBox(box3Values, Corner.topLeft, Corner.bottomRight));
              subBoxes.add(RecursiveBox(box4Values, Corner.bottomLeft, Corner.topRight));
              subBoxes.add(RecursiveBox(box2Values, Corner.bottomRight, Corner.topRight));
            }
            else{ //if endCorner == Corner.bottomLeft
              subBoxes.add(RecursiveBox(box1Values, Corner.topLeft, Corner.topRight));
              subBoxes.add(RecursiveBox(box2Values, Corner.topLeft, Corner.bottomRight));
              subBoxes.add(RecursiveBox(box4Values, Corner.topRight, Corner.bottomLeft));
              subBoxes.add(RecursiveBox(box3Values, Corner.bottomRight, Corner.bottomLeft));
            }
          }
          else{ //even-odd or odd-even
            if(width % 2 == 0){ //odd-even
              assert(endCorner == Corner.topRight);
              //make it eo-xx
              if(height % 2 != 0){
                heightFirstHalf = height - heightFirstHalf;
              }
              box1Values = List.generate(heightFirstHalf, (int heightIndex) => List.generate(widthFirstHalf, (int widthIndex) => (values[heightIndex][widthIndex])));
              box2Values = List.generate(heightFirstHalf, (int heightIndex) => List.generate(width - widthFirstHalf, (int widthIndex) => (values[heightIndex][widthFirstHalf + widthIndex])));
              box3Values = List.generate(height - heightFirstHalf, (int heightIndex) => List.generate(widthFirstHalf, (int widthIndex) => (values[heightFirstHalf + heightIndex][widthIndex])));
              box4Values = List.generate(height - heightFirstHalf, (int heightIndex) => List.generate(width - widthFirstHalf, (int widthIndex) => (values[heightFirstHalf + heightIndex][widthFirstHalf + widthIndex])));
              if(widthFirstHalf > 1){
                subBoxes.add(RecursiveBox(box1Values, Corner.topLeft, Corner.bottomLeft));
                subBoxes.add(RecursiveBox(box3Values, Corner.topLeft, Corner.topRight));
                subBoxes.add(RecursiveBox(box4Values, Corner.topLeft, Corner.topRight));
                subBoxes.add(RecursiveBox(box2Values, Corner.bottomRight, Corner.topRight));
              }
              else{
                subBoxes.add(RecursiveBox(box1Values, Corner.topLeft, Corner.bottomLeft));
                subBoxes.add(RecursiveBox(box3Values, Corner.topLeft, Corner.bottomRight));
                subBoxes.add(RecursiveBox(box4Values, Corner.bottomLeft, Corner.topRight));
                subBoxes.add(RecursiveBox(box2Values, Corner.bottomRight, Corner.topRight));
              }
            }
            else{ //even-odd
              assert(endCorner == Corner.bottomLeft);
              //make it xx-eo
              if(width % 2 != 0){
                widthFirstHalf = width - widthFirstHalf;
              }
              box1Values = List.generate(heightFirstHalf, (int heightIndex) => List.generate(widthFirstHalf, (int widthIndex) => (values[heightIndex][widthIndex])));
              box2Values = List.generate(heightFirstHalf, (int heightIndex) => List.generate(width - widthFirstHalf, (int widthIndex) => (values[heightIndex][widthFirstHalf + widthIndex])));
              box3Values = List.generate(height - heightFirstHalf, (int heightIndex) => List.generate(widthFirstHalf, (int widthIndex) => (values[heightFirstHalf + heightIndex][widthIndex])));
              box4Values = List.generate(height - heightFirstHalf, (int heightIndex) => List.generate(width - widthFirstHalf, (int widthIndex) => (values[heightFirstHalf + heightIndex][widthFirstHalf + widthIndex])));
              if(heightFirstHalf > 1){
                subBoxes.add(RecursiveBox(box1Values, Corner.topLeft, Corner.topRight));
                subBoxes.add(RecursiveBox(box2Values, Corner.topLeft, Corner.bottomLeft));
                subBoxes.add(RecursiveBox(box4Values, Corner.topLeft, Corner.bottomLeft));
                subBoxes.add(RecursiveBox(box3Values, Corner.bottomRight, Corner.bottomLeft));
              }
              else{
                subBoxes.add(RecursiveBox(box1Values, Corner.topLeft, Corner.topRight));
                subBoxes.add(RecursiveBox(box2Values, Corner.topLeft, Corner.bottomRight));
                subBoxes.add(RecursiveBox(box4Values, Corner.topRight, Corner.bottomLeft));
                subBoxes.add(RecursiveBox(box3Values, Corner.bottomRight, Corner.bottomLeft));
              }
            }
          }
        }
      }
      //split into 3x3 boxes if path going straight diagonally
      else{
        assert(width != 0 && height != 0);
        int widthFirstThird = (width/3.0).round();
        int heightFirstThird = (height/3.0).round();
        if(height % 2 == 0){ //oeo-ooo
          if(widthFirstThird % 2 == 0){
            widthFirstThird = width - (2*widthFirstThird);
          }
          if(heightFirstThird % 2 == 0){
            if(heightFirstThird != 2){
              if(height > 0){heightFirstThird++;}
              if(height < 0){heightFirstThird--;}
            }
          }
        }
        else{ //ooo-oeo
          if(heightFirstThird % 2 == 0){
            heightFirstThird = height - (2*heightFirstThird);
          }
          if(widthFirstThird % 2 == 0){
            if(widthFirstThird != 2){
              if(width > 0){widthFirstThird++;}
              if(width < 0){widthFirstThird--;}
            }
          }
        }
        List<List<int>> box1Values = List.generate(heightFirstThird, (int heightIndex) => List.generate(widthFirstThird, (int widthIndex) => (values[heightIndex][widthIndex])));
        List<List<int>> box2Values = List.generate(heightFirstThird, (int heightIndex) => List.generate(width - 2*widthFirstThird, (int widthIndex) => (values[heightIndex][widthFirstThird + widthIndex])));
        List<List<int>> box3Values = List.generate(heightFirstThird, (int heightIndex) => List.generate(widthFirstThird, (int widthIndex) => (values[heightIndex][width - widthFirstThird + widthIndex])));
        List<List<int>> box4Values = List.generate(height - 2*heightFirstThird, (int heightIndex) => List.generate(widthFirstThird, (int widthIndex) => (values[heightFirstThird + heightIndex][widthIndex])));
        List<List<int>> box5Values = List.generate(height - 2*heightFirstThird, (int heightIndex) => List.generate(width - 2*widthFirstThird, (int widthIndex) => (values[heightFirstThird + heightIndex][widthFirstThird + widthIndex])));
        List<List<int>> box6Values = List.generate(height - 2*heightFirstThird, (int heightIndex) => List.generate(widthFirstThird, (int widthIndex) => (values[heightFirstThird + heightIndex][width - widthFirstThird + widthIndex])));
        List<List<int>> box7Values = List.generate(heightFirstThird, (int heightIndex) => List.generate(widthFirstThird, (int widthIndex) => (values[height - heightFirstThird + heightIndex][widthIndex])));
        List<List<int>> box8Values = List.generate(heightFirstThird, (int heightIndex) => List.generate(width - 2*widthFirstThird, (int widthIndex) => (values[height - heightFirstThird + heightIndex][widthFirstThird + widthIndex])));
        List<List<int>> box9Values = List.generate(heightFirstThird, (int heightIndex) => List.generate(widthFirstThird, (int widthIndex) => (values[height - heightFirstThird + heightIndex][width - widthFirstThird + widthIndex])));
        if(width < height){
          subBoxes.add(RecursiveBox(box1Values, Corner.topLeft, Corner.bottomRight));
          subBoxes.add(RecursiveBox(box2Values, Corner.bottomLeft, Corner.topRight));
          subBoxes.add(RecursiveBox(box3Values, Corner.topLeft, Corner.bottomRight));
          subBoxes.add(RecursiveBox(box6Values, Corner.topRight, Corner.bottomLeft));
          subBoxes.add(RecursiveBox(box5Values, Corner.bottomRight, Corner.topLeft));
          subBoxes.add(RecursiveBox(box4Values, Corner.topRight, Corner.bottomLeft));
          subBoxes.add(RecursiveBox(box7Values, Corner.topLeft, Corner.bottomRight));
          subBoxes.add(RecursiveBox(box8Values, Corner.bottomLeft, Corner.topRight));
          subBoxes.add(RecursiveBox(box9Values, Corner.topLeft, Corner.bottomRight));
        }
        else{ //if width >= height
          subBoxes.add(RecursiveBox(box1Values, Corner.topLeft, Corner.bottomRight));
          subBoxes.add(RecursiveBox(box4Values, Corner.topRight, Corner.bottomLeft));
          subBoxes.add(RecursiveBox(box7Values, Corner.topLeft, Corner.bottomRight));
          subBoxes.add(RecursiveBox(box8Values, Corner.bottomLeft, Corner.topRight));
          subBoxes.add(RecursiveBox(box5Values, Corner.bottomRight, Corner.topLeft));
          subBoxes.add(RecursiveBox(box2Values, Corner.bottomLeft, Corner.topRight));
          subBoxes.add(RecursiveBox(box3Values, Corner.topLeft, Corner.bottomRight));
          subBoxes.add(RecursiveBox(box6Values, Corner.topRight, Corner.bottomLeft));
          subBoxes.add(RecursiveBox(box9Values, Corner.topLeft, Corner.bottomRight));
        }
      }
    }
    
    //rotate sub-boxes to have their starting corner be the top left one - this works and we don't need to keep track of rotations
    // b/c we only care about the order in which boxes are being traversed, not any graphical path
    List<RecursiveBox> rotatedSubBoxes = new List<RecursiveBox>();
    subBoxes.forEach((box) => rotatedSubBoxes.add(RecursiveBox.topLeftCorner(box)));
    return rotatedSubBoxes;
  }
}