package magicGame.repositories.interfaces;

import magicGame.models.magics.Magic;

import java.util.ArrayList;
import java.util.Collection;

import static magicGame.common.ExceptionMessages.*;

public class MagicRepositoryImpl implements MagicRepository{
    private Collection<Magic> data;

    public MagicRepositoryImpl() {
        this.data = new ArrayList<>();
    }

    @Override
    public Collection getData() {
        return this.data;
    }

    @Override
    public void addMagic(Magic model) {
        if (model==null) {
            throw new NullPointerException(INVALID_MAGIC_REPOSITORY);
        }
        data.add(model);

    }

    @Override
    public boolean removeMagic(Magic model) {

     return this.data.remove(model);
    }

    @Override
    public Object findByName(String name) {


        return data.stream().filter(m -> m.getName().equals(name)).findFirst().orElse(null);
    }
}