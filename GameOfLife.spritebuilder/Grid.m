//
//  Grid.m
//  GameOfLife
//
//  Created by Arman Suleimenov on 7/4/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Grid.h"
#import "Creature.h"

static const int GRID_ROWS = 8;
static const int GRID_COLUMNS = 10;

@implementation Grid {
    NSMutableArray * _gridArray;
    float _cellWidth;
    float _cellHeight;
}

- (void) onEnter {
    [super onEnter];
    
    [self setupGrid];
    
    // accept touches on the grid
    self.userInteractionEnabled = YES;
}

-(void) evolveStep{
    [self countNeighbors];
    [self updateCreatures];
    _generation++;
}

- (BOOL)_isIndexValidForX:(int)x andY:(int)y {
    return x >= 0 && x < GRID_ROWS && y >= 0 && y < GRID_COLUMNS;
}

- (void) countNeighbors {
    for(int i = 0; i < [_gridArray count]; ++i) {
        
        for(int j = 0; j < [_gridArray[i] count]; ++j) {
            Creature * creature = _gridArray[i][j];
            creature.livingNeighbors = 0;
            
            for(int x = i - 1; x <= i + 1; ++x) {
                for(int y = j - 1; y <= j + 1; ++y) {
                    
                    if(x == i && y == j) continue;
                    if([self _isIndexValidForX:x andY:y]) {
                        Creature * neighbor = _gridArray[x][y];
                        if(neighbor.isAlive) {
                            creature.livingNeighbors++;
                        }
                    }
                    
                }
            }
        }
    }
}

- (void) updateCreatures {
    int aliveCount = 0;
    for(int i = 0; i < [_gridArray count]; ++i) {
        for(int j = 0; j < [_gridArray count]; ++j) {
            Creature * creature = _gridArray[i][j];
            if(creature.livingNeighbors == 3) {
                creature.isAlive = YES;
                aliveCount++;
            } else {
                if(creature.livingNeighbors <= 1 || creature.livingNeighbors >= 4)
                    creature.isAlive = NO;
            }
        }
    }
    _totalAlive = aliveCount;
}

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    CGPoint touchLocation = [touch locationInNode:self];
    
    Creature * creature = [self creatureForTouchPosition:touchLocation];
    
    creature.isAlive = !creature.isAlive;
}

- (Creature *)creatureForTouchPosition:(CGPoint)touchPosition {
    //get the row and column that was touched, return the Creature inside the corresponding cell
    int j = touchPosition.x / _cellWidth;
    int i = touchPosition.y / _cellHeight;
    return _gridArray[i][j];
}

- (void) setupGrid {
    _cellWidth = self.contentSize.width / GRID_COLUMNS;
    _cellHeight = self.contentSize.height / GRID_ROWS;
    
    float x = 0;
    float y = 0;
    
    _gridArray = [NSMutableArray array];
    
    for(int i = 0; i < GRID_ROWS; ++i) {
        x = 0;
        _gridArray[i] = [NSMutableArray array];
        for(int j = 0; j < GRID_COLUMNS; ++j) {
            Creature * creature = [[Creature alloc] initCreature];
            creature.anchorPoint = ccp(0, 0);
            creature.position = ccp(x, y);
            [self addChild:creature];
            
            _gridArray[i][j] = creature;
            x += _cellWidth;
        }
        y += _cellHeight;
    }
}

@end
