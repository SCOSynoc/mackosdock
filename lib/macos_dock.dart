import 'package:flutter/material.dart';

// MacOSDock is widget which will build whole list of icons inside the container
class MacOSDock extends StatelessWidget {
  const MacOSDock({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      /// the property for defining initial route we are passing
      /// scaffold to create visual of material widget
      home: Scaffold(
        /// primary content of scaffold which we are aligning with center widget
        body: Center(
          /// Here we are passing our custom DOCK widget as child of center widget
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (e) {
              return Container(
                constraints: const BoxConstraints(minWidth: 48),
                height: 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[e.hashCode % Colors.primaries.length],
                ),
                child: Center(child: Icon(e, color: Colors.white)),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Dock of the draggable and reorderable [items].
class Dock<T extends Object> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Initial [T] items to put in this [Dock].
  final List<T> items;

  /// Builder function for building the provided [T] item.
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T extends Object> extends State<Dock<T>>
    with SingleTickerProviderStateMixin {
  late List<T> _items = widget.items.toList();

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize the AnimationController for smooth animation
    _controller = AnimationController(
      /// this will defines the duration of animation
      duration: const Duration(milliseconds: 500),
      /// this will define that the animation is for current context
      vsync: this,
    );

    // this animation offset will track change in positions
    _slideAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.bounceInOut));
  }

  /// this dispose will never build widget again
  @override
  void dispose() {
    /// this method of animation controller will dispose ticker animation
    _controller.dispose();
    super.dispose();
  }

  // this method is created to start the slide animation
  void _startSlideAnimation() {
    /// this method will restart the animation
    _controller.repeat();
    /// as this animation offset is late initialized we are initializing it here
    _slideAnimation = Tween<Offset>(
      // this property will begin animation from -0.2
      begin: const Offset(-0.2, 0),
      // this property will end it to 0
      end: const Offset(0, 0),
    )
    /// this method gives the animation
    .animate(
      /// so we are providing curved animation to it
        CurvedAnimation(
        /// this property indicate where this animation must be applied
        parent: _controller,
        /// as there are variety of curve animations we are selected easeInOut
        curve: Curves.easeInOut));
    /// this will function will start running the animation from forward to end
    _controller.forward();
  }

  /// this method will build Container widget.
  @override
  Widget build(BuildContext context) {
    return Container(
      /// this property is use for decorating container background
      decoration: BoxDecoration(
        /// this property will give radius to container
        borderRadius: BorderRadius.circular(12),
        /// this property will change color of container
        color: Colors.black12,
      ),
      /// this property will give padding to container
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      /// this property is used to create our dock widget inside the container
      child: buildDock(),
    );
  }

  /// we have wrapped our dock element row widget in method for better read
  Row buildDock() {
    return Row(
      /// this property will keep row size to min
      mainAxisSize: MainAxisSize.min,
      /// this will wrap list of icons in row we are passing list.generate to it which create list and give access to its index
      children: List.generate(_items.length, (index) {
        // this variable is created for tracking particular item
        final item = _items[index];
        // we are wrapping our icons list inside a drag target
        // as our initial object and target object is same
        return DragTarget<int>(
          builder: (context, candidateData, rejectedData) {
            // we are wrapping this inside animation builder which build animation in context
            return AnimatedBuilder(
              /// here we will our slide animation offset
              animation: _slideAnimation,
              builder: (context, child) {
                /// this widget will enables us to drag our element (icons)
                return Draggable<int>(
                  /// when we drag this function will call
                  onDragStarted: () {
                    /// inside this function we will start slide animation
                    _startSlideAnimation();
                  },
                  /// this property will uniquely identify particular element
                  key: ValueKey(item),
                  /// this will create a widget when we drag our element
                  /// and making changes to it by Transform.scale which will scale its size
                  feedback: Transform.scale(
                    /// scale icons size
                    scale: 1,
                    /// this build our widget when we drag
                    child: widget.builder(item),
                  ),
                  /// this property will make animation to a child when we drag our icon
                  /// from it were we are just passing sizedbox
                  childWhenDragging: SizedBox(
                      /// here we are animating child width using our animation offset
                    /// as it will keep changing because of single ticker provider
                      width: 60 * _slideAnimation.value.distance ,
                      height: 60),
                  /// this property is building our initial row elements.
                  child: widget.builder(item),
                );
              },
            );
          },
        );
      }),
    );
  }
}