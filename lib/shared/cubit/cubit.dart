import 'package:flag_master/shared/cubit/states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class GameCubit extends Cubit<GameStates> {
  GameCubit() : super(GameInitialState());
  static GameCubit get(context) => BlocProvider.of(context);


}
