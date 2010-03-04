package Collision::Util::Entity::Point;
use Mouse;
extends 'Collision::Util::Entity';

use overload '""'  => sub{'point'};



#I daresay, 2 points mayn't collide
sub collide_point{
   return;
}


#Here, $self is assumed to be normalized.

sub collide_rect{
   my ($self, $rect, %params) = @_;
   #if we start inside rect, return the null collision, so to speak.
   #if ($rect->contains_point($self)){
   #   return $self->null_collision($rect)
   #}
   #this line segment is path of point during this interval
   my $x1 = $self->relative_x;
   my $x2 = $x1 + ($self->relative_xv * $params{interval});
   my $y1 = $self->relative_y;
   my $y2 = $y1 + ($self->relative_yv * $params{interval});
   
   #if it contains point at t=0, relatively...
   if (  $x1>0 and $x1<$rect->w
     and $y1>0 and $y1<$rect->h){
      return $self->null_collision;
   }
   else{
      #start outside box, so return if no relative movement 
      return unless $params{interval} and ($self->relative_x or $self->relative_y);
   }
   
   #now see if point starts and ends on one of 4 sides of this rect.
   #probably worth it because most things don't collide with each other every frame
   if ($x1 > $rect->w and $x2 > $rect->w ){
      return
   }
   if ($x1 < 0 and $x2 < 0){
      return
   }
   if ($y1 > $rect->h and $y2 > $rect->h ){
      return
   }
   if ($y1 < 0 and $y2 < 0){
      return
   }
   
   #not that simple. either it enters rect, or passes by a corner. check each rect line segment.
   my ($best_time, $best_axis);
   
   if ($self->relative_xv){
      if ($x1 < 0 and $x2 > 0){ # horizontally pass rect's left side
         my $t = (-$x1) / $self->relative_xv;
         my $y_at_t = $y1 + ($t * $self->relative_yv);
         if ($y_at_t < $rect->h  and  $y_at_t > 0) {
            $best_time = $t;
            $best_axis = 'x';
         }
      }
      elsif ($x1 > $rect->w and $x2 < $rect->w){ #horizontally pass rect's right side
         my $t = ($x1 - $rect->w) / -$self->relative_xv;
         my $y_at_t = $y1 + ($t * $self->relative_yv);
         if ($y_at_t < $rect->h  and  $y_at_t > 0) {
            $best_time = $t;
            $best_axis = 'x';
         }
      }
   }
   if ($self->relative_yv){
      if ($y1 < 0 and $y2 > 0){ #vertically pass rect's lower side
         my $t = (-$y1) / $self->relative_yv;
         if (!defined($best_time) or $t < $best_time){
            my $x_at_t = $x1 + ($t * $self->relative_xv);
            if ($x_at_t < $rect->w  and  $x_at_t > 0) {
               $best_time = $t;
               $best_axis = 'y';
            }
         }
      }
      elsif ($y1 > $rect->h and $y2 < $rect->h){ #vertically pass rect's upper side
         my $t = ($y1 - $rect->w) / -$self->relative_xv;
         if (!defined($best_time) or $t < $best_time){
            my $x_at_t = $x1 + ($t * $self->relative_xv);
            if ($x_at_t < $rect->w  and  $x_at_t > 0) {
               $best_time = $t;
               $best_axis = 'y';
            }
         }
      }
   }
   return unless $best_axis;
   return Collision::Util::Collision->new(
      time => $best_time,
      axis => $best_axis,
      ent1 => $self,
      ent2 => $rect,
   );
}


2
